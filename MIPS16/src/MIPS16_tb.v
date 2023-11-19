`timescale 1ns / 1ps

module MIPS16_tb();
    // Inputs
    reg clk;
    reg reset;
    
    // Outputs
    wire [15:0] pc_out;
    wire [15:0] alu_result;//,reg3,reg4;
    
    // Instantiate the Unit Under Test (UUT)
    MIPS16 uut (
    .clk(clk),
    .reset(reset),
    .pc_out(pc_out),
    .alu_result(alu_result)
    //.reg3(reg3),
    // .reg4(reg4)
    );
    initial begin
        clk             = 0;
        forever #10 clk = ~clk;
    end
    initial begin
        // Initialize Inputs
        //$monitor ("register 3 = %d, register 4 = %d", reg3,reg4);
        reset                   = 1;
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        // Add stimulus here
        #5000; $finish;
    end

    initial begin 
        $dumpfile("MIPS16.vcd");
        $dumpvars(0, MIPS16_tb);
    end
endmodule
