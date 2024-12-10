/*
Special Values in IEEE 754
1- If exp and mantissa are zero the number is +- Zero
2- If Exp all one and Mantissa All zero the number is +- Infinity
3- If exp all one and mantissa not all zero the number is NaN
*/
module fpu_top(
    input [31:0] num1, num2,
    input [3:0] op,
    output [31:0] result    
); 
reg [31:0] fpu_res;
wire [31:0] sum_sub_result, mult_result;

localparam [3:0]
    ADD = 4'b0000,
    SUB = 4'b0001,
    MUL = 4'b0010,
    DIV = 4'b0011;
/*
The Addition operation is Done in 4 Stages

Stage 1: Sort the numbers such as the number with larger magnitude is in num1_sorted
Stage 2: Align the exponent of the smaller number to the exponent of the larger number
Stage 3: Add/Subtract Mantissa
Stage 4: Normalize the result
*/
// wire num1_exp_zero, num2_exp_zero;
// wire num1_mantissa_zero, num2_mantissa_zero;
// wire num1_exp_one, num2_exp_one;
// wire num1_mantissa_one, num2_mantissa_one;

fp_adder fp_adder_u(
    .num1(num1),
    .num2(num2),
    .add_sub(op[0]),
    .result(sum_sub_result)
);

fp_multiplier fp_multiplier_u(
    .mantissa_num1(num1[22:0]),
    .mantissa_num2(num2[22:0]),
    .normilized_bit_num1(1'b1),
    .normilized_bit_num2(1'b1),
    .sign_num1(num1[31]),
    .sign_num2(num2[31]),
    .exp_num1(num1[30:23]),
    .exp_num2(num2[30:23]),
    .result(mult_result)
);

always @(*) begin
    case(op)
        ADD: fpu_res = sum_sub_result;
        SUB: fpu_res = sum_sub_result;
        MUL: fpu_res = mult_result;
        default: fpu_res = 32'hB00B5;       
    endcase

end
assign result = fpu_res;

endmodule

