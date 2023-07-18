`timescale 1ns / 1ps

module smpl_circuit(output x,
                    output y,
                    input A,
                    input B,
                    input C);
    wire e;
    and g1(e,A,B);
    not g2(y, C);
    or g3(x,e,y);
endmodule
