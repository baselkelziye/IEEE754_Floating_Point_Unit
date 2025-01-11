`timescale 1ns/1ps

module fpu_top_tb;

    // Inputs
    reg [31:0] num1;
    reg [31:0] num2;
    reg [3:0] op; // not used in this case, but provided for completeness
    reg clk, rst;
    
 initial begin 
    clk = 0;
    forever begin
    #10 clk = ~clk;
 end end

    // Outputs
    wire [31:0] result; // not used in the provided module, but connected for completeness

    // Instantiate the fpu_top module
    fpu_top uut (
    		.clk(clk),
    		.rst(rst),
        .num1(num1),
        .num2(num2),
        .op(op),
        .result(result)
    );

    // Task to display results
    task display_results;
        input [31:0] num1, num2, bigger_number, smaller_number;
        begin
            $display("Num1: %b (%e)", num1, $bitstoreal(num1));
            $display("Num2: %b (%e)", num2, $bitstoreal(num2));
            $display("Bigger: %b (%e)", bigger_number, $bitstoreal(bigger_number));
            $display("Smaller: %b (%e)\n", smaller_number, $bitstoreal(smaller_number));
        end
    endtask

    // Monitor output from comparator_fp
    // wire [31:0] num1_sorted, num2_sorted;

    initial begin
    	  rst = 1'b1;
    	  #10;
    	  rst = 1'b0;
    	  #10;
        // Test cases
        $display("Starting simulation...");

        // Test 1: num1 > num2
        num1 = 32'h41200000; // 10.0 in IEEE754
        num2 = 32'h40A00000; // 5.0 in IEEE754
        op = 4'b0000; // Operation code, unused here
        #10; // Wait for outputs to stabilize
        

//         // Test 2: num1 < num2
         num1 = 32'h40400000; // 3.0 in IEEE754
         num2 = 32'h40A00000; // 5.0 in IEEE754
         #10; // Wait for outputs to stabilize
        

// //        // Test 3: num1 == num2
         num1 = 32'h3F800000; // 1.0 in IEEE754
         num2 = 32'h3F800000; // 1.0 in IEEE754
         #10; // Wait for outputs to stabilize
        

// //        // Test 4: num1 and num2 with negative values
         num1 = 32'hC1200000; // -10.0 in IEEE754
         num2 = 32'h40A00000; // 5.0 in IEEE754
         #10; // Wait for outputs to stabilize
        

// //        // Test 5: num1 and num2 are both negative
         num1 = 32'hC1200000; // -10.0 in IEEE754
         num2 = 32'hC0400000; // -3.0 in IEEE754
         #10; // Wait for outputs to stabilize
        
         num1 = 32'h422B28F6; //42.79
         num2 = 32'h418C6666; //17.55
         #10;
        
         num1 = 32'b0_10000011_10011000000000000000000; // 25.5
         num2 = 32'b1_01111101_10000000000000000000000; // -0.375

//num1 = 81.43933868408203
//num2 = 70.47241973876953
         num1 = 32'h42a2e0f1; //81.43933868408203
         num2 = 32'h428cf1e1; //70.47241973876953
       #10;
        

        $display("Simulation completed.");
        $stop;
    end
endmodule
