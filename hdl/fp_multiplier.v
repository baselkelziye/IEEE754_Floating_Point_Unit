module fp_multiplier
(
    input [31:0] num1, num2,
    input [1:0] rounding_mode,
    output [31:0] result    
);

localparam [1:0]
ROUND_TO_NEAREST      = 2'b00,
ROUND_TO_ZERO         = 2'b01,
ROUND_TO_POSITIVE_INF = 2'b10,
ROUND_TO_NEGATIVE_INF = 2'b11;

wire result_sign;
wire [47:0] mantissa_product;
reg  [22:0] normalised_mantissa_r1, normalised_mantissa_final;
wire [24:0] normalised_mantissa_r2;
wire [8:0 ] exp_product;
reg  [8:0 ] normalised_exp_r1, normalised_exp_final;
reg guard_bit, round_bit, sticky_bit, round_decision; // GRS bits for rounding
wire is_result_exact;


wire [7:0] exp_num1, exp_num2;
wire sign_num1, sign_num2;
wire normilized_bit_num1, normilized_bit_num2;
wire [22:0] mantissa_num1, mantissa_num2;

assign exp_num1 = num1[30:23];
assign exp_num2 = num2[30:23];

assign mantissa_num1 = num1[22:0];
assign mantissa_num2 = num2[22:0];

assign sign_num1 = num1[31];
assign sign_num2 = num2[31];

assign normilized_bit_num1 = 1'b1;
assign normilized_bit_num2 = 1'b1;


wire [2:0] GRS;
assign GRS = {guard_bit, round_bit, sticky_bit};
assign is_result_exact = ~|GRS; //If the result is exact no rounding is

//If signs are different result is negative
assign result_sign  = sign_num1 ^ sign_num2;

assign exp_product = exp_num1 + exp_num2 - 127;

assign mantissa_product = {normilized_bit_num1, mantissa_num1} * {normilized_bit_num2, mantissa_num2};

//Normlize Step 1
always @(*) begin
    if(mantissa_product[47]) begin
        normalised_mantissa_r1 = mantissa_product[46:24]; //Shift 1 to right
        normalised_exp_r1 = exp_product + 1'b1;
        guard_bit = mantissa_product[23];
        round_bit = mantissa_product[22];
        sticky_bit = |mantissa_product[21:0];
    end 
    else begin
        normalised_mantissa_r1 = mantissa_product[45:23];
        normalised_exp_r1 = exp_product;
        guard_bit = mantissa_product[22];
        round_bit = mantissa_product[21];
        sticky_bit = |mantissa_product[20:0];
    end
end

//Rounding bit decision
always@*
begin
if(is_result_exact) //If the result is exact no rounding is needed
    round_decision = 1'b0;
else
    case(rounding_mode)
    ROUND_TO_ZERO: round_decision = 1'b0;
    ROUND_TO_NEAREST:
    begin
        if(GRS > 3'b100)
            round_decision = 1'b1;
        else if (GRS < 3'b100)
            round_decision = 1'b0;
        else
            round_decision = normalised_mantissa_r1[0];
            /*
            if GRS = 100 there is 2 options round up or down
            After rounding the LSB of mantissa shall be even (0)
            so if the LSB is 1, round bit shall be 1 thus the sum will be even
            if the LSB is 0, round bit shall be 0 thus the sum will be even
            for more information check slide page 22:
            https://ee.usc.edu/~redekopp/cs356/slides/CS356Unit3_FP.pdf
            */
    end
    ROUND_TO_POSITIVE_INF: round_decision = ~result_sign; // If Numbers is positive, round up, if negative round down 
    ROUND_TO_NEGATIVE_INF: round_decision = result_sign; // If Numbers is positive, round down, if negative round up
    endcase
end

//Rounding be sure to append the hidden bit while adding.
assign normalised_mantissa_r2 = {1'b1,normalised_mantissa_r1} + {22'b0, round_decision};

//After rounding a second normalisation might be needed
always @(*)
begin
    if(normalised_mantissa_r2[24])
    begin //After we round, there is an overflow
        normalised_mantissa_final = normalised_mantissa_r2[23:1];
        normalised_exp_final = normalised_exp_r1[7:0]  + 1'b1;
    end 
    else
    begin
        normalised_mantissa_final = normalised_mantissa_r2[22:0]; 
        normalised_exp_final = normalised_exp_r1;
    end
end

assign result = {result_sign, normalised_exp_final[7:0], normalised_mantissa_final};

endmodule