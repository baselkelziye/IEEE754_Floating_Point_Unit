`timescale 1ns / 1ps

module fp_multiplier_tb;

    // Testbench signals
    reg [31:0] num1, num2;
    reg [1:0] rounding_mode;
    wire [31:0] result;

    // Instantiate the module under test (DUT)
    fp_multiplier uut (
        .num1(num1),
        .num2(num2),
        .rounding_mode(rounding_mode),
        .result(result)
    );

    initial begin
        // Initialize inputs
        num1 = 32'h3FE87CF5; // 1.81631338596344
        num2 = 32'h3F0CF1E1; // 0.550565779209137

        // Apply test case 1: rounding_mode = 2'b00
        rounding_mode = 2'b00; // Round to nearest
        #10; // Wait 10 time units
        $display("Test Case 1: Rounding Mode = 2'b00\nnum1 = %h, num2 = %h, result = %h", num1, num2, result);

        // Apply test case 2: rounding_mode = 2'b01
        rounding_mode = 2'b01; // Round toward zero
        #10; // Wait 10 time units
        $display("Test Case 2: Rounding Mode = 2'b01\nnum1 = %h, num2 = %h, result = %h", num1, num2, result);

        // End simulation
        $stop;
    end

endmodule