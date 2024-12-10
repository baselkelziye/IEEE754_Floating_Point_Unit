module fp_multiplier(
    input [22:0] mantissa_num1, mantissa_num2,
    input normilized_bit_num1, normilized_bit_num2, //Currently Hardcoded to 1'b1
    input sign_num1, sign_num2,
    input [7:0] exp_num1, exp_num2,
    output [31:0] result    
);

wire result_sign, round_bit;
wire [47:0] mantissa_product;
reg  [22:0] normalised_mantissa_r1, normalised_mantissa_final;
wire [23:0] normalised_mantissa_r2;
wire [8:0] exp_product;
reg  [8:0] normalised_exp_r1, normalised_exp_final;

//If signs are different result is negative
assign result_sign  = sign_num1 ^ sign_num2;

assign exp_product = exp_num1 + exp_num2 - 127;

assign mantissa_product = {normilized_bit_num1, mantissa_num1} * {normilized_bit_num2, mantissa_num2};
assign round_bit = |mantissa_product[22:0];

//Normlize Round 1
always @(*) begin
    if(mantissa_product[47]) begin
        normalised_mantissa_r1 = mantissa_product[46:24]; //Shift 1 to right
        normalised_exp_r1 = exp_product + 1'b1;
    end 
    else begin
        normalised_mantissa_r1 = mantissa_product[45:23];
        normalised_exp_r1 = exp_product;
    end
end


//Rounding
assign normalised_mantissa_r2 = normalised_mantissa_r1 + round_bit;

//Normalize Round 2
always @(*) begin
    if(normalised_mantissa_r2[23]) begin //After we round, there is an overflow
        normalised_mantissa_final = normalised_mantissa_r2[23:1];
        normalised_exp_final = normalised_exp_r1  + 1'b1;
    end 
    else begin
        normalised_mantissa_final = normalised_mantissa_r2[22:0]; 
        normalised_exp_final = normalised_exp_r1;
    end

end


assign result = {result_sign, normalised_exp_final[7:0], normalised_mantissa_final};

endmodule