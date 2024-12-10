
module fp_adder(
    input [31:0] num1, num2,
    input add_sub, //If 0 its Add operation if 1 Sub
    output [31:0] result    
);

wire [31:0] num1_sorted, num2_sorted;
wire [7:0] exp_num1, exp_num2, exp_diff, exp_aligned;
wire [23:0] mantissa_num1, mantissa_num2, mantissa_aligned; //Mantisaa is 24 bit (1 extra bit for the implicit 1)
reg [24:0] sum;
reg [22:0] result_mantissa;
wire [22:0] norm_mantissa;
reg [7:0] result_exp;
wire [4:0] clz_sum;
wire num2_sign_bit;
//Fields extraction

//If Subtraction, invert the sign bit of num2
assign num2_sign_bit = num2[31] ^ add_sub;


//Stage 1 Sorting
assign {num1_sorted, num2_sorted} = (num1[30:0] > num2[30:0]) ? {num1, {num2_sign_bit, num2[30:0]}} : {{num2_sign_bit, num2[30:0]}, num1};

assign exp_num1 = num1_sorted[30:23];
assign exp_num2 = num2_sorted[30:23];

//TODO: If expo is zero then the number is denormilized (0.XXXX)
assign mantissa_num1 = {1'b1,num1_sorted[22:0]}; 
assign mantissa_num2 = {1'b1,num2_sorted[22:0]};


//Stage 2 Aligning the Exponent
assign exp_diff = exp_num1 - exp_num2;
assign mantissa_aligned = mantissa_num2 >> exp_diff;



//Stage 3 Mantissa Addition
always @* begin
	if(num1_sorted[31] == num2_sorted[31])
		sum = {1'b0, mantissa_num1} + {1'b0, mantissa_aligned};
	else
		sum = {1'b0, mantissa_num1} - {1'b0, mantissa_aligned};
end

clz clz_unit(
    .in(sum[23:0]),
    .count(clz_sum)
);
assign norm_mantissa = sum << clz_sum;
//Stage 4 Normalization
always @* begin
    if(sum[24]) begin // IF there is a carry, shift to right and Increment Exponent
        result_mantissa = sum[23:1];
        result_exp = exp_num1 + 1;
    end 
    else if (clz_sum > exp_num1 - 127) begin // If the result is too small, return 0
        result_mantissa = 22'b0;
        result_exp = 8'b0; 
    end
    else begin 
        result_mantissa = norm_mantissa;
        result_exp = exp_num1 - clz_sum;
    end
end

assign result = {num1_sorted[31], result_exp, result_mantissa};



endmodule