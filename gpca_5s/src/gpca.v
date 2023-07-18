`timescale 1ns / 1ps

// Arithmetic Cell
module ac (input wire A,
           input wire B,
           input wire C,
           input wire X,
           input wire F,
           input wire C1,
           output wire S,
           output wire D,
           output wire E,
           output wire C0);
   
    assign S  = ((A ^ (B ^ X) ^ C1) & F) | (A & ~F);
    assign C0 = ((B ^ X) & (A | C1)) | (A & C1);
    assign D  = C & (B | F);
    assign E  = B | (C & F);
endmodule

// Control Cell
module cc (
    input wire X, P, C0,
    output wire F
    );
    assign F = (C0 & X) | (P & ~X);
endmodule
       
module gpca
    (
    input wire X,
    input wire [1:5] P,
    input wire [1:7] B, C,
    input wire [1:10] A,
    output wire [1:5] F,
    output wire [1:11] S
    );
   
    wire [1:7]  FI;
    wire [1:3]  C1;
    wire [1:5]  C2;
    wire [1:7]  C3;
    wire [1:9]  C4;
   
    wire [1:11] C5;
   
    wire [1:3]  S1;
    wire [1:5]  S2;
    wire [1:7]  S3;
    wire [1:9]  S4;
    wire [1:11] S5;
    wire [1:3]  D1;
    wire [1:5]  D2;
    wire [1:7]  D3;
    wire [1:9]  D4;
    wire [1:11] D5;
   
    wire [1:3]  E1;
    wire [1:5]  E2;
    wire [1:7]  E3;
    wire [1:9]  E4;
    wire [1:11] E5;
   
    assign F[1] = C1[1];
    assign F[2] = C2[1];
    assign F[3] = C3[1];
    assign F[4] = C4[1];
    assign F[5] = C5[1];
    //
   
    assign S = S5;
    //control cells (X,P,C0 / F)
    cc cc1(X, P[1], C1[1], FI[1]);
    cc cc2(X, P[2], C2[1], FI[2]);
    cc cc3(X, P[3], C3[1], FI[3]);
    cc cc4(X, P[4], C4[1], FI[4]);
    cc cc5(X, P[5], C5[1], FI[5]);
   
    //_______________________________________________________________
    // arithmetic cells of row 1(A,B,C,X,F,C1/S,D,E,C0)
    ac ac11(.A(1'b0), .B(B[1]),.C(C[1]),.X(X),.F(FI[1]),.C1(C1[2]),
    .S(S1[1]), .D(D1[1]), .E(E1[1]),.C0(C1[1]));
    ac ac12(.A(A[1]), .B(B[2]),.C(C[2]),.X(X),.F(FI[1]),.C1(C1[3]),
    .S(S1[2]), .D(D1[2]), .E(E1[2]),.C0(C1[2]));
    ac ac13(.A(A[2]), .B(B[3]),.C(C[3]),.X(X),.F(FI[1]),.C1(X),.S(S1[3]), .D(D1[3]),
    .E(E1[3]),.C0(C1[3]));
   
    // arithmetic cells of row 2(A,B,C,X,F,C1/S,D,E,C0)
    ac ac21(.A(S1[1]), .B(1'b0),.C(1'b0),.X(X),.F(FI[2]),
    .C1(C2[2]),.S(S2[1]), .D(D2[1]), .E(E2[1]),.C0(C2[1]));
    ac ac22(.A(S1[2]), .B(D1[1]), .C(E1[1]), .X(X),.F(FI[2]),
    .C1(C2[3]), .S(S2[2]), .D(D2[2]), .E(E2[2]),.C0(C2[2]));
    ac ac23(.A(S1[3]), .B(D1[2]), .C(E1[2]), .X(X),.F(FI[2]),
    .C1(C2[4]), .S(S2[3]), .D(D2[3]), .E(E2[3]),.C0(C2[3]));
    ac ac24(.A(A[3]), .B(D1[3]), .C(E1[3]),.X(X),.F(FI[2]),
    .C1(C2[5]), .S(S2[4]), .D(D2[4]),.E(E2[4]),.C0(C2[4]));
    ac ac25(.A(A[4]),.B(B[4]),.C(C[4]),.X(X),.F(FI[2]),
    .C1(X),.S(S2[5]), .D(D2[5]),.E(E2[5]),.C0(C2[5]));
   
    // arithmetic cells of row 3(A,B,C,X,F,C1/S,D,E,C0)
    ac ac31(.A(S2[1]),.B(1'b0),.C(1'b0),.X(X),.F(FI[3]),
    .C1(C3[2]),.S(S3[1]), .D(D3[1]), .E(E3[1]),.C0(C3[1]));
    ac ac32(.A(S2[2]), .B(D2[1]), .C(E2[1]), .X(X),.F(FI[3]),
    .C1(C3[3]), .S(S3[2]), .D(D3[2]), .E(E3[2]),.C0(C3[2]));
    ac ac33(.A(S2[3]), .B(D2[2]), .C(E2[2]), .X(X),.F(FI[3]),
    .C1(C3[4]), .S(S3[3]), .D(D3[3]), .E(E3[3]),.C0(C3[3]));
    ac ac34(.A(S2[4]), .B(D2[3]), .C(E2[3]), .X(X),.F(FI[3]),
    .C1(C3[5]), .S(S3[4]), .D(D3[4]), .E(E3[4]),.C0(C3[4]));
    ac ac35(.A(S2[5]), .B(D2[4]), .C(E2[4]), .X(X),.F(FI[3]),
    .C1(C3[6]), .S(S3[5]), .D(D3[5]), .E(E3[5]),.C0(C3[5]));
    ac ac36(.A(A[5]), .B(D2[5]), .C(E2[5]),.X(X),.F(FI[3]),
    .C1(C3[7]), .S(S3[6]), .D(D3[6]),.E(E3[6]),.C0(C3[6]));
    ac ac37(.A(A[6]),.B(B[5]),.C(C[5]),.X(X),.F(FI[3]),
    .C1(X),.S(S3[7]), .D(D3[7]),.E(E3[7]),.C0(C3[7]));
   
    // arithmetic cells of row 4(A,B,C,X,F,C1/S,D,E,C0)
    ac ac41(.A(S3[1]), .B(1'b0),.C(1'b0),.X(X),.F(FI[4]),
    .C1(C4[2]),.S(S4[1]), .D(D4[1]), .E(E4[1]),.C0(C4[1]));
    ac ac42(.A(S3[2]), .B(D3[1]), .C(E3[1]), .X(X),.F(FI[4]),
    .C1(C4[3]), .S(S4[2]), .D(D4[2]), .E(E4[2]),.C0(C4[2]));
    ac ac43(.A(S3[3]), .B(D3[2]), .C(E3[2]), .X(X),.F(FI[4]),
    .C1(C4[4]), .S(S4[3]), .D(D4[3]), .E(E4[3]),.C0(C4[3]));
    ac ac44(.A(S3[4]), .B(D3[3]), .C(E3[3]), .X(X),.F(FI[4]),
    .C1(C4[5]), .S(S4[4]), .D(D4[4]), .E(E4[4]),.C0(C4[4]));
    ac ac45(.A(S3[5]), .B(D3[4]), .C(E3[4]), .X(X),.F(FI[4]),
    .C1(C4[6]), .S(S4[5]), .D(D4[5]), .E(E4[5]),.C0(C4[5]));
    ac ac46(.A(S3[6]), .B(D3[5]), .C(E3[5]), .X(X),.F(FI[4]),
    .C1(C4[7]), .S(S4[6]), .D(D4[6]), .E(E4[6]),.C0(C4[6]));
    ac ac47(.A(S3[7]), .B(D3[6]), .C(E3[6]), .X(X),.F(FI[4]),
    .C1(C4[8]), .S(S4[7]), .D(D4[7]), .E(E4[7]),.C0(C4[7]));    
    ac ac48(.A(A[7]), .B(D3[7]), .C(E3[7]), .X(X),
            .F(FI[4]),
            .C1(C4[9]), .S(S4[8]), .D(D4[8]), .E(E4[8]),
            .C0(C4[8]));
   
    ac ac49(.A(A[8]), .B(B[6]),.C(C[6]),.X(X),.F(FI[4]),
    .C1(X),.S(S4[9]), .D(D4[9]),.E(E4[9]),.C0(C4[9]));
   
    // arithmetic cells of row 5(A,B,C,X,F,C1/S,D,E,C0)
    ac ac51(.A(S4[1]), .B(1'b0),.C(1'b0),.X(X),.F(FI[5]),
    .C1(C5[2]),.S(S5[1]), .D(D5[1]), .E(E5[1]),.C0(C5[1]));
    ac ac52(.A(S4[2]), .B(D4[1]), .C(E4[1]), .X(X),.F(FI[5]),
    .C1(C5[3]), .S(S5[2]), .D(D5[2]), .E(E5[2]),.C0(C5[2]));
    ac ac53(.A(S4[3]), .B(D4[2]), .C(E4[2]), .X(X),.F(FI[5]),
    .C1(C5[4]), .S(S5[3]), .D(D5[3]), .E(E5[3]),.C0(C5[3]));
    ac ac54(.A(S4[4]), .B(D4[3]), .C(E4[3]), .X(X),.F(FI[5]),
    .C1(C5[5]), .S(S5[4]), .D(D5[4]), .E(E5[4]),.C0(C5[4]));
    ac ac55(.A(S4[5]), .B(D4[4]), .C(E4[4]), .X(X),.F(FI[5]),
    .C1(C5[6]), .S(S5[5]), .D(D5[5]), .E(E5[5]),.C0(C5[5]));
    ac ac56(.A(S4[6]), .B(D4[5]), .C(E4[5]), .X(X),.F(FI[5]),
    .C1(C5[7]), .S(S5[6]), .D(D5[6]), .E(E5[6]),.C0(C5[6]));
    ac ac57(.A(S4[7]), .B(D4[6]), .C(E4[6]), .X(X),.F(FI[5]),
    .C1(C5[8]), .S(S5[7]), .D(D5[7]), .E(E5[7]),.C0(C5[7]));
    ac ac58(.A(S4[8]), .B(D4[7]), .C(E4[7]), .X(X),.F(FI[5]),
    .C1(C5[9]), .S(S5[8]), .D(D5[8]), .E(E5[8]),.C0(C5[8]));
    ac ac59(.A(S4[9]), .B(D4[8]), .C(E4[8]), .X(X),.F(FI[5]),
    .C1(C5[10]),.S(S5[9]), .D(D5[9]), .E(E5[9]),.C0(C5[9]));
    ac ac5a(.A(A[9]), .B(D4[9]), .C(E4[9]),.X(X),.F(FI[5]),
    .C1(C5[11]),.S(S5[10]), .D(D5[10]),.E(E5[10]),.C0(C5[10]));
    ac ac5b(.A(A[10]), .B(B[7]),.C(C[7]),.X(X),.F(FI[5]),
    .C1(X),.S(S5[11]), .D(D5[11]), .E(E5[11]),.C0(C5[11]));
endmodule
