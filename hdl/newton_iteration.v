module newton_iteration(
    input  [31:0] divisor, xn,
    output [31:0] xn_1
);

wire [31:0] xn_mult_divisor, const2_minus_Nxn;
wire [31:0] constant_2;

assign constant_2 = 32'h4000_0000; // 2.0 in IEEE754

// N * Xn
fp_multiplier xn_mult_divisor_u(
    .num1(xn               ),
    .num2(divisor          ),
    .rounding_mode(2'b00   ),
    .result(xn_mult_divisor)
);

// 2.0 - N * Xn
fp_adder const2_minus_N_xn_u(
    .num1(constant_2        ),
    .num2(xn_mult_divisor   ),
    .add_sub(1'b1           ), // For subtraction.
    .result(const2_minus_Nxn)
);

// Xn (2 - N * Xn)
fp_multiplier xn_mult_const2_minus_N_xn_u(
    .num1(xn              ),
    .num2(const2_minus_Nxn),
    .rounding_mode(2'b00  ),
    .result(xn_1          )
);

endmodule