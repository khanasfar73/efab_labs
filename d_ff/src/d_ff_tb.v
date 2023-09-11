`timescale 1ns / 1ps

module d_ff_tb();
    reg clk, din, n_rst;
    wire q, d1, clk1;
    d_ff UUT(q, clk, n_rst, din);
    assign d1   = din;
    assign clk1 = clk;
    initial clk = 1'b0;
        always #10 clk = ~clk;
        initial begin
            din       = 1'b0;
            n_rst     = 1'b1;
            #20 n_rst = 1'b0;
            #10 din   = 1'b1;
            #20 n_rst = 1'b1;
            #18 din   = 1'b0;
            #1 din    = 1'b1;
            #20 din   = 1'b0;
            #10 $stop;
        end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, d_ff_tb);
    end
endmodule
    
