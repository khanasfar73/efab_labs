`timescale 1ns / 1ps

module alu_tb;
    parameter WIDTH = 16;
    parameter BITS = 4;

    reg C_in;
    reg [WIDTH - 1 : 0] A, B;
    reg [BITS - 1: 0] ALU_opcode;

    wire [WIDTH - 1 : 0] ALU_result;
    wire S, Z, C, V;

    alu DUT(A, B, ALU_opcode, ALU_result, C_in, S, Z, C, V);

    initial
    begin
        $dumpfile("waveform_alu.vcd");
        $dumpvars(0, alu_tb);

        #10;
        ALU_opcode = 0;
        A = 10;
        B = 5;
        C_in = 0;

        #10;
        ALU_opcode = 1;
        A = 10;
        B = 10;
        C_in = 0;

        #10 $finish;
    end
endmodule
