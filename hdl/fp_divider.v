module fp_divider
(
    input [31:0] num1, num2,
    input [1:0] rounding_mode,
    output [31:0] result   
);

wire [31:0] const_48_div_17, const_minus_32_div_17;
wire [31:0] initial_x0_value, tmp_32_17_mult_divisor;
wire [31:0] xn1_value, xn2_value, xn3_value;
wire [31:0] divisor, shifted_num1, reciprocal;
wire [7:0 ] shift, shifted_exp_a, reciprocal_exp;
wire [31:0] tmp_res;
wire sign_res;

assign  const_48_div_17       = 32'h4034_B4B5; // 48/17 in IEEE754
assign  const_minus_32_div_17 = 32'hbff0f0f1; // -32/17 in IEEE754

assign divisor = {1'b0, 8'd126, num2[22:0]}; //Make Divisor unsigned and between 0.5 and 1

assign shift  = 8'd126 - num2[30:23]; //Calculate the shift required to make the divisor between 0.5 and 1
assign shifted_exp_a = num1[30:23] + shift; //Shift the exponent of num1 by the same amount as divisor 
assign shifted_num1 = {num1[31], shifted_exp_a, num1[22:0]}; //Shift num1 by the same amount as divisor

assign sign_res = num1[31] ^ num2[31]; 
//Initial Seed = 48/17 + (-32/17) * Divisor

// (-32 /17 ) * Divisor
fp_multiplier const_minus_32_div_17_mult_divisor_u(
    .num1(const_minus_32_div_17),
    .num2(divisor),
    .rounding_mode(rounding_mode),
    .result(tmp_32_17_mult_divisor)
);

// 48/17 + (-32/17) * Divisor
fp_adder const_48_div_17_plus_tmp_32_17_mult_divisor_u(
    .num1(const_48_div_17),
    .num2(tmp_32_17_mult_divisor), // -32/17 * Divisor 
    .add_sub(1'b0), // For addition.
    .result(initial_x0_value)
);


//Newton Iteration 1
newton_iteration newton_iteration_1_u(
    .divisor(divisor),
    .xn(initial_x0_value),
    .xn_1(xn1_value)
);


//Newton Iteration 2
newton_iteration newton_iteration_2_u(
    .divisor(divisor),
    .xn(xn1_value),
    .xn_1(xn2_value)
);

//Newton Iteration 3
newton_iteration newton_iteration_3_u(
    .divisor(divisor),
    .xn(xn2_value),
    .xn_1(xn3_value)
);

// Num1 * 1/Num2

fp_multiplier num1_mult_reciprocal_u(
    .num1(shifted_num1),
    .num2(xn3_value),
    .rounding_mode(rounding_mode),
    .result(tmp_res)
);

assign result = {sign_res, tmp_res[30:0]};


endmodule