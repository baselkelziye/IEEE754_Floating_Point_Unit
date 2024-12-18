
module fp_adder(
    input [31:0] num1, num2,
    input [7:0] exp_num1, exp_num2,
    input sign_num1, sign_num2,
    input [22:0] mantissa_num1, mantissa_num2,
    input normilized_bit_num1, normilized_bit_num2,
    input add_sub, //If 0 its Add operation if 1 Sub
    output [31:0] result    
);


wire [7:0]  exp_diff;
wire [23:0] mantissa_aligned; //Mantisaa is 24 bit (1 extra bit for the implicit 1)
reg [24:0] sum;
reg [22:0] mantissa_norm1_result, mantissa_norm2_result;
wire [23:0] mantissa_rounded;
reg [7:0] exp_norm1_result, exp_norm2_result;
wire [4:0] clz_sum_norm1, clz_sum_norm2;
wire num2_sign_bit;
reg [23:0] mantissa_large, mantissa_small;
reg [7:0] exp_large, exp_small;
reg sign_large, sign_small;
wire guard_bit, rounding_bit, sticky_bit, round_decision;
//If Subtraction, invert the sign bit of num2
assign num2_sign_bit = sign_num2 ^ add_sub;

//Stage 1 Sorting
always @(*)
begin
    if({exp_num1, mantissa_num1} > {exp_num2, mantissa_num2})
    begin
        mantissa_large = {normilized_bit_num1, mantissa_num1};
        mantissa_small = {normilized_bit_num2, mantissa_num2};
        exp_large      = exp_num1;
        exp_small      = exp_num2;
        sign_large     = sign_num1;
        sign_small     = num2_sign_bit;        
    end
    else
    begin
        mantissa_large = {normilized_bit_num2, mantissa_num2};
        mantissa_small = {normilized_bit_num1, mantissa_num1};
        exp_large      = exp_num2;
        exp_small      = exp_num1;
        sign_large     = num2_sign_bit;
        sign_small     = sign_num1;
    end
end

//Stage 2 Aligning the Exponent
assign exp_diff = exp_large - exp_small;
assign mantissa_aligned = mantissa_small >> exp_diff;

assign guard_bit = mantissa_small[1];
assign rounding_bit = mantissa_small[0];
assign sticky_bit = |mantissa_small[22:2];


//Stage 3 Mantissa Addition
always @* begin
	if(sign_large == sign_small)
		sum = {1'b0, mantissa_large} + {1'b0, mantissa_aligned};
	else
		sum = {1'b0, mantissa_large} - {1'b0, mantissa_aligned};
end

//Stage 4 Normalization
clz clz_norm1(
    .in(sum[23:0]),
    .count(clz_sum_norm1)
);

always @* begin
    if(sum[24]) begin // IF there is a carry, shift to right and Increment Exponent
        mantissa_norm1_result = sum[23:1];
        exp_norm1_result = exp_large + 1;
    end 
    else if (clz_sum_norm1 > exp_large - 127) begin // If the result is too small, return 0
        mantissa_norm1_result = 22'b0;
        exp_norm1_result = 8'b0; 
    end
    else begin 
        mantissa_norm1_result = sum << clz_sum_norm1;
        exp_norm1_result = exp_large - clz_sum_norm1;
    end
end

//Rounding Decision
assign rounding_decision = guard_bit & (rounding_bit | sticky_bit);
assign mantissa_rounded = mantissa_norm1_result + rounding_decision;

//Step 5 Normalization 2
clz clz_norm2(
    .in({1'b0,mantissa_rounded[22:0]}),
    .count(clz_sum_norm2)
);

always @*
begin
    if(mantissa_rounded[23])
    begin
        mantissa_norm2_result = mantissa_rounded[23:1];
        exp_norm2_result = exp_norm1_result + 1;
    end
    else if(clz_sum_norm2 - 1 > exp_norm1_result - 127)
    begin
        mantissa_norm2_result = 22'b0;
        exp_norm2_result = 8'b0;
    end
    else
    begin
        mantissa_norm2_result = mantissa_norm1_result;
        exp_norm2_result = exp_norm1_result;
    end
end

assign result = {sign_large, exp_norm2_result, mantissa_norm2_result};
endmodule