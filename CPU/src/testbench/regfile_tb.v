`timescale 1ns / 1ps

module regfile_tb #(WORD = 32)();
    reg [WORD - 1 : 0] data;
    reg [4:0] rda, rdb, waddr;
    reg we, clk, rstn;
    wire [WORD - 1 : 0] qa, qb;

    regfile DUT(data, rda, rdb, waddr, we, clk, rstn, qa, qb);

    always #5 clk = ~clk;

    initial
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, regfile_tb);

        #5 clk = 0;
        rstn = 0;
        rda = 0;
        rdb = 1;
        we = 0;

        #5;
        rstn = 1;
        rda = 1;
        rdb = 2;
        waddr = 5;

        #10;
        rda = 0;
        rdb = 5;
        data = 44;
        we = 1;

        #10;
        waddr = 7;
        data = 23;
        rda = 7;

        #20 $finish;
    end
endmodule
