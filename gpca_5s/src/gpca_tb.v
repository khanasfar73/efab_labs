module gpca_tb();
    // Inputs
    reg X;
    reg [1:5] P;
    reg [1:7] B;
    reg [1:7] C;
    reg [1:10] A;
   
    // Outputs
    wire [1:5] F;
    wire [1:11] S;
   
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
   
    initial begin
        // Initialize Inputs
        X = 0; P = 0; B = 0; A = 0; C = 0;
        #200;
       
        // Multiplication 7*5, P = 5 (Right justified), B = 7 (Left  justified)
        X = 0; P = 5'b00101; A = 0; B = 7'b1110000; C = 7'b1110000;
        #200;
       
        // Squaring 5^2, P = 5 (Right justified), B = first two bits 0's and all others 1, C = first bit 0, second bit 1, all others 0, A = 0
        X = 0; P = 5'b00101; A = 0; B = 7'b001111111; C = 7'b0100000;
        #200;
       
        // Square Root of 25, P = 0, B = first two bits 0's and all others 1, C = first bit 0, second bit 1, all others 0, Input in A (as right justified)
        X = 1; P = 5'b00000; A = 10'b0000011001; B = 9'b001111111; C = 9'b010000000;
        #200;
       
        // Division 35/5; A = 35 (left justified), B = C = 5, P = 0
        X = 1; P = 5'b00000; A = 10'b1100_0100_00; B = 7'b1010_000; C = 7'b1010_000;
        #200;
       
    end
endmodule
