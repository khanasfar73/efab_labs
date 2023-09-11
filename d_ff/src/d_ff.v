`timescale 1ns / 1ps

module d_ff(output reg q,
            input clk,
            input n_rst,
            input din);
    
    always @(posedge clk or negedge n_rst)
    begin
        if (!n_rst)
            q <= 1'b0;
        else
            q <= din;
    end
endmodule
