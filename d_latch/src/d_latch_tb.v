`timescale 1ns / 1ps

module d_latch_tb;
  reg e, d;
  wire q;
  d_latch uut (.e(e),.d(d),.q(q) );
  initial begin
    d = 0;
    e = 0;
  end

  always #30 e = ~e;
  always #50 d = ~d;
  
  initial begin
    #1000 $finish;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, d_latch_tb);
  end
endmodule
