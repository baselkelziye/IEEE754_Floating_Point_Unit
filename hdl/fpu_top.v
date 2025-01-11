/*
Special Values in IEEE 754
1- If exp and mantissa are zero the number is +- Zero
2- If Exp all one and Mantissa All zero the number is +- Infinity
3- If exp all one and mantissa not all zero the number is NaN
*/
module fpu_top(
    input clk, rst,
    input [31:0] num1, num2,
    input [3:0] op,
    output [31:0] result    
); 
reg [31:0] fpu_res;
wire [31:0] sum_sub_result, mult_result, div_result;
wire fp_divider_start;

localparam [3:0]
    ADD = 4'b0000,
    SUB = 4'b0001,
    MUL = 4'b0010,
    DIV = 4'b0011;

fp_adder fp_adder_u(
    .num1(num1),
    .num2(num2),
    .add_sub(op[0]),
    .result(sum_sub_result)
);

fp_multiplier fp_multiplier_u(
    .num1(num1),
    .num2(num2),
    .rounding_mode(2'b00),
    .result(mult_result)
);


fp_divider fp_divider_u(
    .num1(num1),
    .num2(num2),
    .rounding_mode(2'b00),
    .result(div_result)
);

always @(*) begin
    case(op)
        ADD: fpu_res = sum_sub_result;
        SUB: fpu_res = sum_sub_result;
        MUL: fpu_res = mult_result;
        DIV: fpu_res = div_result;
        default: fpu_res = 32'hB00B5;       
    endcase

end
assign result = fpu_res;

endmodule

