// decode instrcutions to feed to Control Unit

module op_decode(
        instr,
        opcode, rd, rs1, rs2, funct3, funct7, imm_I, imm_S, imm_B, imm_U, imm_J
    );

    input [31:0] instr;

    output [6:0] opcode;
    output [5:0] rd, rs1, rs2;
    output [2:0] funct3;
    output [6:0] funct7;

    // Immediates in various instrcution modes
    output [11:0] imm_I;    // 12-bit immediate
    output [11:0] imm_S;    // 12-bit immediate
    output [11:0] imm_B;    // 12-bit immediate
    output [19:0] imm_U;    // 20-bit immediate
    output [19:0] imm_J;    // 20-bit immediate

    assign opcode = instr[6:0];
    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    assign imm_I = instr[31:20];
    assign imm_S = {instr[31:25], instr[11:7]};
    assign imm_B = {instr[31], instr[7], instr[30:25], instr[11:8]};
    assign imm_U = instr[31:12];
    assign imm_J = {instr[31], instr[19:12], instr[20], instr[30:21]};
endmodule
