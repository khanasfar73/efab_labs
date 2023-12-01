`timescale 1ns/ 1ps

module rtl_tb;
    bit clk, rstn;
    wire [4:0] c;

    rtl #(.BITS(5)) DUT(clk, rstn, c);

    always #5 clk = ~clk;

    initial begin
        clk = 1; rstn = 0;

        #3 rstn = 1;

        #300 $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, rtl_tb);
    end
endmodule
