`timescale 1ns / 1ps
module MIPS16 (
    input clk,
    input reset,
    output [15:0] pc_out, alu_result
);
    reg [15:0] pc_current;
    wire signed [15:0] pc_next, pc2;
    wire [15:0] instr;
    wire [1:0] reg_dst, mem_to_reg, alu_op;
    wire jump, branch, mem_read, mem_write, alu_src, reg_write;
    wire [2:0]  reg_write_dest;
    wire [15:0] reg_write_data;
    wire [2:0]  reg_read_addr_1;
    wire [15:0] reg_read_data_1;
    wire [2:0]  reg_read_addr_2;
    wire [15:0] reg_read_data_2;
    wire [15:0] sign_ext_im,read_data2,zero_ext_im,imm_ext;
    wire JRControl;
    wire [2:0] ALU_Control;
    wire [15:0] ALU_out;
    wire zero_flag;
    wire signed[15:0] im_shift_1, PC_j, PC_beq, PC_4beq,PC_4beqj,PC_jr;
    wire beq_control;
    wire [14:0] jump_shift_1;
    wire [15:0]mem_read_data;
    wire [15:0] no_sign_ext;
    wire sign_or_zero;
    
    // PC
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            pc_current <= 16'd0;
        else
            pc_current <= pc_next;
    end

    // PC + 2
    assign pc2 = pc_current + 16'd2;
    // instruction memory
    instr_mem instrucion_memory(.pc(pc_current),.instruction(instr));
    // jump shift left 1
    assign jump_shift_1 = {instr[13:0],1'b0};
    // control unit
    control control_unit(
        .reset(reset),
        .opcode(instr[15:13]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .sign_or_zero(sign_or_zero)
    );

    // multiplexer regdest
    assign reg_write_dest = (reg_dst == 2'b10) ? 3'b111: ((reg_dst == 2'b01) ? instr[6:4] :instr[9:7]);

    // register file
    assign reg_read_addr_1 = instr[12:10];
    assign reg_read_addr_2 = instr[9:7];

    register_file reg_file(
        .clk(clk),
        .rst(reset),
        .reg_write_en(reg_write),
        .reg_write_dest(reg_write_dest),
        .reg_write_data(reg_write_data),
        .reg_read_addr_1(reg_read_addr_1),
        .reg_read_data_1(reg_read_data_1),
        .reg_read_addr_2(reg_read_addr_2),
        .reg_read_data_2(reg_read_data_2)
    );
    //.reg3(reg3),
    //.reg4(reg4));

    // sign extend
    assign sign_ext_im = {{9{instr[6]}},instr[6:0]};
    assign zero_ext_im = {{9{1'b0}},instr[6:0]};
    assign imm_ext     = (sign_or_zero == 1'b1) ? sign_ext_im : zero_ext_im;
    // JR control
    JR_Control JRControl_unit(.alu_op(alu_op),.funct(instr[3:0]),.JRControl(JRControl));
    // ALU control unit
    ALUControl ALU_Control_unit(.ALUOp(alu_op),.Function(instr[3:0]),.ALU_Control(ALU_Control));
    // multiplexer alu_src
    assign read_data2 = (alu_src == 1'b1) ? imm_ext : reg_read_data_2;
    // ALU
    alu alu_unit(.a(reg_read_data_1),.b(read_data2),.alu_control(ALU_Control),.result(ALU_out),.zero(zero_flag));
    // immediate shift 1
    assign im_shift_1 = {imm_ext[14:0],1'b0};
    //
    assign no_sign_ext = ~(im_shift_1) + 1'b1;
    // PC beq add
    assign PC_beq = (im_shift_1[15] == 1'b1) ? (pc2 - no_sign_ext): (pc2 +im_shift_1);
    // beq control
    assign beq_control = branch & zero_flag;
    // PC_beq
    assign PC_4beq = (beq_control == 1'b1) ? PC_beq : pc2;
    // PC_j
    assign PC_j = {pc2[15],jump_shift_1};
    // PC_4beqj
    assign PC_4beqj = (jump == 1'b1) ? PC_j : PC_4beq;
    // PC_jr
    assign PC_jr = reg_read_data_1;
    // PC_next
    assign pc_next = (JRControl == 1'b1) ? PC_jr : PC_4beqj;
    // data memory
    data_memory datamem(
        .clk(clk),
        .mem_access_addr(ALU_out),
        .mem_write_data(reg_read_data_2),.mem_write_en(mem_write),.mem_read(mem_read),
        .mem_read_data(mem_read_data)
    );

    // write back
    assign reg_write_data = (mem_to_reg == 2'b10) ? pc2:((mem_to_reg == 2'b01)? mem_read_data: ALU_out);
    // output
    assign pc_out     = pc_current;
    assign alu_result = ALU_out;
endmodule


module register_file (
        input clk,
        input rst,
        input reg_write_en,
        input [2:0] reg_write_dest,
        input [15:0] reg_write_data,
        input [2:0] reg_read_addr_1,
        output [15:0] reg_read_data_1,
        input [2:0] reg_read_addr_2,
        output [15:0] reg_read_data_2
    );
    reg     [15:0]     reg_array [7:0];

    // write port
    //reg [2:0] i;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            reg_array[0] <= 16'b0;
            reg_array[1] <= 16'b0;
            reg_array[2] <= 16'b0;
            reg_array[3] <= 16'b0;
            reg_array[4] <= 16'b0;
            reg_array[5] <= 16'b0;
            reg_array[6] <= 16'b0;
            reg_array[7] <= 16'b0;
        end
        else begin
            if (reg_write_en) begin
                reg_array[reg_write_dest] <= reg_write_data;
            end
        end
    end
    assign reg_read_data_1 = (reg_read_addr_1 == 0)? 16'b0 : reg_array[reg_read_addr_1];
    assign reg_read_data_2 = (reg_read_addr_2 == 0)? 16'b0 : reg_array[reg_read_addr_2];
endmodule


module instr_mem (
    input [15:0] pc,
    output wire [15:0] instruction
);
    wire [3 : 0] rom_addr = pc[4 : 1];
    /* lw     $3, 0($0) --
     Loop:     slti $1, $3, 50
     beq $1, $0, Skip
     add $4, $4, $3
     addi $3, $3, 1
     beq $0, $0, Loop--
     Skip
     */
    reg [15:0] rom[15:0];
    
    initial begin
        rom[0]  = 16'b1000000110000000;
        rom[1]  = 16'b0010110010110010;
        rom[2]  = 16'b1101110001100111;
        rom[3]  = 16'b1101110111011001;
        rom[4]  = 16'b1111110110110001;
        rom[5]  = 16'b1100000001111011;
        rom[6]  = 16'b0000000000000000;
        rom[7]  = 16'b0000000000000000;
        rom[8]  = 16'b0000000000000000;
        rom[9]  = 16'b0000000000000000;
        rom[10] = 16'b0000000000000000;
        rom[11] = 16'b0000000000000000;
        rom[12] = 16'b0000000000000000;
        rom[13] = 16'b0000000000000000;
        rom[14] = 16'b0000000000000000;
        rom[15] = 16'b0000000000000000;
    end
    assign instruction = (pc[15:0] < 32)? rom[rom_addr[3:0]]: 16'd0;
endmodule


module data_memory (
    input clk,
    input [15:0] mem_access_addr,
    input [15:0] mem_write_data,
    input mem_write_en,
    input mem_read,
    output [15:0] mem_read_data
);

    integer i;
    reg [15:0] ram [255:0];
    wire [7:0] ram_addr = mem_access_addr [8:1];

    initial begin
        for(i = 0;i<256;i = i+1)
            ram[i] <= 16'd0;
    end

    always @(posedge clk) begin
        if (mem_write_en)
            ram[ram_addr] <= mem_write_data;
    end

    assign mem_read_data = (mem_read == 1'b1) ? ram[ram_addr]: 16'd0;
endmodule

module control(
    input[2:0] opcode,
    input reset,
    output reg [1:0] reg_dst,
    mem_to_reg,
    alu_op,
    output reg jump,
    branch,
    mem_read,
    mem_write,
    alu_src,
    reg_write,
    sign_or_zero
);

    always @(*) begin
        if (reset == 1'b1) begin
            reg_dst      = 2'b00;
            mem_to_reg   = 2'b00;
            alu_op       = 2'b00;
            jump         = 1'b0;
            branch       = 1'b0;
            mem_read     = 1'b0;
            mem_write    = 1'b0;
            alu_src      = 1'b0;
            reg_write    = 1'b0;
            sign_or_zero = 1'b1;
        end
        else begin
            case(opcode)
                3'b000: begin // add
                    reg_dst      = 2'b01;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b00;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b0;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b1;
                end
                3'b001: begin // sli
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b10;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b1;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b0;
                end
                3'b010: begin // j
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b00;
                    jump         = 1'b1;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b0;
                    reg_write    = 1'b0;
                    sign_or_zero = 1'b1;
                end
                3'b011: begin // jal
                    reg_dst      = 2'b10;
                    mem_to_reg   = 2'b10;
                    alu_op       = 2'b00;
                    jump         = 1'b1;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b0;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b1;
                end
                3'b100: begin // lw
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b01;
                    alu_op       = 2'b11;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b1;
                    mem_write    = 1'b0;
                    alu_src      = 1'b1;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b1;
                end
                3'b101: begin // sw
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b11;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b1;
                    alu_src      = 1'b1;
                    reg_write    = 1'b0;
                    sign_or_zero = 1'b1;
                end
                3'b110: begin // beq
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b01;
                    jump         = 1'b0;
                    branch       = 1'b1;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b0;
                    reg_write    = 1'b0;
                    sign_or_zero = 1'b1;
                end
                3'b111: begin // addi
                    reg_dst      = 2'b00;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b11;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b1;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b1;
                end
                default: begin
                    reg_dst      = 2'b01;
                    mem_to_reg   = 2'b00;
                    alu_op       = 2'b00;
                    jump         = 1'b0;
                    branch       = 1'b0;
                    mem_read     = 1'b0;
                    mem_write    = 1'b0;
                    alu_src      = 1'b0;
                    reg_write    = 1'b1;
                    sign_or_zero = 1'b1;
                end
            endcase
        end
    end
endmodule


module ALUControl (
    output reg [2:0] ALU_Control,
    input [1:0]ALUOp,
    input [3:0] Function
);

    wire [5:0] ALUControlIn;

    assign ALUControlIn = {ALUOp,Function};

    always @(ALUControlIn)
        casex (ALUControlIn)
            6'b11xxxx: ALU_Control = 3'b000;
            6'b10xxxx: ALU_Control = 3'b100;
            6'b01xxxx: ALU_Control = 3'b001;
            6'b000000: ALU_Control = 3'b000;
            6'b000001: ALU_Control = 3'b001;
            6'b000010: ALU_Control = 3'b010;
            6'b000011: ALU_Control = 3'b011;
            6'b000100: ALU_Control = 3'b100;
            default: ALU_Control   = 3'b000;
        endcase
endmodule


// Verilog code for JR control unit
module JR_Control(input [1:0] alu_op, input [3:0] funct, output JRControl);
    assign JRControl = ({alu_op,funct} == 6'b001000) ? 1'b1 : 1'b0;
endmodule


module alu(
    input [15:0] a,           //src1
    input [15:0] b,           //src2
    input [2:0] alu_control,  //function sel
    output reg [15:0] result, //result
    output zero
);

    always @(*)
    begin
        case(alu_control)
            3'b000: result                = a + b; // add
            3'b001: result                = a - b; // sub
            3'b010: result                = a & b; // and
            3'b011: result                = a | b; // or
            3'b100: begin 
                if (a<b) result = 16'd1;
                else result     = 16'd0;
            end
            default:result = a + b; // add
        endcase
    end
    assign zero = (result == 16'd0) ? 1'b1: 1'b0;
endmodule
