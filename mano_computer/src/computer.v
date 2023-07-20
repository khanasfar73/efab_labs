module computer(
        input IR0, IR1, clock,
        output t0, t1, t2, t3, t4, x1, x2, x3, x4, x5, x6, x7, q1, q2, q3
    );
    reg SysClk = 0;
    reg [7:0] mem[0:8], MAR, MBR, IR, A, R, PC;
    reg [2:0] T;

    wire q1, q2, q3,t0, t1, t2, t3, t4, t5, t6, t7, x1, x2, x3, x4, x5, x6, x7, x8;
    reg reset;

    OpDecoder opl(IR0, IR1, q1, q2, q3);
    TimeDecoder tmr1(T, t0, t1, t2, t3, t4, t5, t6, t7);
    Logic log1(q1, q2, q3, t0, t1, t2, t3, t4, t5, t6, t7, x1, x2, x3, x4, x5, x6, x7, x8);

    always @(reset)
    begin
        SysClk = 0;
        MAR = 0;
        MBR = 0;
        PC = 8'b00000000;
        IR = 0;
        A = 0;
        R = 0;
        T = 0;
    end

    always @(posedge x1 or posedge x2)
        if (x1)
            MAR = PC;
        else
            MAR = MBR;

    always @(posedge x3) PC = PC + 1;

    always @(posedge x4) MBR = mem[MAR];

    always @(posedge x5 or posedge x6)
        if (x5)
            A = MBR;
        else
            A = R;

    always @(posedge x7) T = 3'b000;

    always @(posedge SysClk)
        if (!x7)
            T = T + 1;

    always @(posedge x8) IR = MBR;

    reg [25:0]count=0;

    always @(posedge clock)
    begin
        count<=count+1;
        if(count==50_000_000)
        begin
            count<=0;
            SysClk<=~SysClk;
        end
    end

    initial
    begin
        reset = 1;
        #10;
        reset = 0;
    end
endmodule
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
module OpDecoder(ir0, ir1, q1, q2, q3);
    input ir0, ir1;
    output q1, q2, q3;
    wire q1 = ir0 & !ir1,
         q2 = ir1 & !ir0,
         q3 = ir0 & ir1;
endmodule
//----------------------------------------------------------------------
//----------------------------------------------------------------------
module TimeDecoder(t, t0, t1, t2, t3, t4, t5, t6, t7);
    input t;
    output t0, t1, t2, t3, t4, t5, t6, t7;
    wire [2:0] t;
    assign
        t0 = ~t[2] & ~t[1] & ~t[0],
        t1 = ~t[2] & ~t[1] & t[0],
        t2 = ~t[2] & t[1] & ~t[0],
        t3 = ~t[2] & t[1] & t[0],
        t4 = t[2] & ~t[1] & ~t[0],
        t5 = t[2] & ~t[1] & t[0],
        t6 = t[2] & t[1] & ~t[0],
        t7 = t[2] & t[1] & t[0];
endmodule
//---------------------------------------------------------------------
//---------------------------------------------------------------------
module Logic(q1, q2, q3, t0, t1, t2, t3, t4, t5, t6, t7, x1, x2, x3, x4, x5, x6, x7, x8);
    input q1, q2, q3, t0, t1, t2, t3, t4, t5, t6, t7;
    output x1, x2, x3, x4, x5, x6, x7, x8;
    wire #100 x1 = t0 | (q2 & t3) | (q3 & t3),
         x2 = q3 & t5,
         x3 = t1 | (q2 & t4) | (q3 & t4),
         x4 = t1 | (q2 & t4) | (q3 & t4) | (q3 & t6),
         x5 = (q2 & t5) | (q3 & t7),
         x6 = q1 & t3,
         x7 = (q2 & t5) | (q3 & t7) | (q1 & t3),
         x8 = t2;
endmodule
