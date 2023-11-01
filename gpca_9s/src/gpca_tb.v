`timescale 1ns / 1ps

module gpca_tb();
    // Inputs
    reg X;
    reg [1:9] P;
    reg [1:19] B;
    reg [1:19] C;
    reg [1:18] A;
    // Outputs
    wire [1:9] F;
    wire [1:19] S;
    // Instantiate the Unit Under Test (UUT)
    gpca uut (
             .X(X),
             .P(P),
             .B(B),
             .C(C),
             .A(A),
             .F(F),
             .S(S)
         );
    initial
    begin
        // Initialize Inputs
        X = 0;
        P = 0;
        B = 0;
        C = 0;
        A = 0;
        #200;
        // Multiplication 7*5, P = 5 (Right justified), B = 7 (Left justified)
        X = 0;
        P = 9'b0000_00101;
        A = 0;
        B = 19'b1110_0000_0000_0000_000;
        C = 19'b1110_0000_0000_0000_000;
        #200;
        // Squaring 5^2, P = 5 (Right justified), B = first two bits 0's and all others 1, C = first bit 0, second bit 1, all others 0, A = 0
        X = 0;
        P = 9'b0000_00101;
        A = 0;
        B = 19'b0011_1111_1111_1111_111;
        C = 19'b0100_0000_0000_0000_000;
        #200;
        // Square Root of 25, P = 0, B = first two bits 0's and all others 1, C = first bit 0, second bit 1, all others 0, Input in A (as right justified)
        X = 1;
        P = 9'b0000_00000;
        A = 18'b0000_0000_0000_0110_01;
        B = 19'b0011_1111_1111_1111_111;
        C = 19'b0100_0000_0000_0000_000;
        #200;
        // Division 35/5; A = 35 (left justified, B = C = 5, P = 0
        X = 1;
        P = 9'b0000_0000_0;
        A = 18'b1100_0100_00;
        B = 19'b1010_0000_0000_0000_000;
        C = 19'b1010_0000_0000_0000_000;
        #200;
        $finish;
    end
endmodule
