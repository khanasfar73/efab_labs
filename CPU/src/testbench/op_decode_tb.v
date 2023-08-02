module op_decode_tb;
    reg [31:0] instr;
    wire [6:0] opcode;
    wire [5:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    // Immediates in various instrcution modes
    wire [11:0] imm_I;
    wire [11:0] imm_S;
    wire [11:0] imm_B;
    wire [19:0] imm_U;
    wire [19:0] imm_J;

    op_decode DUT(instr, opcode, rd, rs1, rs2, funct3, funct7, imm_I, imm_S, imm_B, imm_U, imm_J);

    initial
    begin
        $dumpfile("waveform_opd.vcd");
        $dumpvars(0, op_decode_tb);

        #10;
        instr = 32'hFFFF;

        #10;
        instr = 32'h0000;

        #10;
        instr = 32'h1234;

        #10;
        instr = 32'h5679;

        #10;
        instr = 32'h9ABC;

        #10;
        instr = 32'hDEF0;

        #10 $finish;
    end
endmodule
