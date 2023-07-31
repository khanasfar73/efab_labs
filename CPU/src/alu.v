module alu #(
        WIDTH = 16,
        BITS = 4
    )
    (A, B, ALU_opcode, ALU_result, C_in, S, Z, C, V);

    input [WIDTH - 1 : 0] A, B;
    input [BITS - 1 : 0] ALU_opcode;
    input C_in;
    output reg [WIDTH - 1 : 0] ALU_result;
    output S, Z, C, V;

    // Flags
    assign S = ALU_result[WIDTH - 1];
    assign Z = C_in;
    assign C = C_in;
    assign V = C_in;

    always @(*)
    begin
        case (ALU_opcode)
            0000:
                // 1. ADD
                ALU_result <= A + B + C_in;
            0001:
                // 2. SUB
                ALU_result <= A - B - C_in;
            0010:
                // 3. MULT
                ALU_result = A * B;
            0011:
                // 4. DIV
                ALU_result <= A / B;
            0100:
                // 5. Bitwide AND
                ALU_result <= A & B;
            0101:
                // 6. Bitwide OR
                ALU_result <= A | B;
            0110:
                // 7. Bitwise XOR
                ALU_result <= A ^ B;
            0111:
                // 8. Bitwise NOT
                ALU_result <= ~A;
            1000: // TODO
                // 9. Shift left
                ALU_result <= 0;
            1001:
                // 10. Shift Right
                ALU_result <= 0;
            1010:
                // 11. Rotate Left
                ALU_result <= 0;
            1011:
                // 12. Rotate Right
                ALU_result <= 0;
            default:
                ALU_result <= 16'bx;
        endcase
    end
endmodule
