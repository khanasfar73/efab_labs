`timescale 1ns / 1ps

module computer_tb();
    // INPUTS
    reg IR0, IR1, clock;
    computer c1(.IR0(IR0), .IR1(IR1), .clock(clock));

    always #10 clock = ~clock;

    initial
    begin
        clock = 0;

        #50;
        c1.R = 99;
        c1.mem[0] = 8'b00000001;
        c1.mem[1] = 8'b00000010;
        c1.mem[2] = 8'b01010101;
        c1.mem[3] = 8'b00000011;
        c1.mem[4] = 220;
        c1.mem[5] = 8'b11000001;
        c1.mem[6] = 8'b00011010;
        c1.mem[7] = 8'b01110101;
        c1.mem[8] = 8'hff;
        c1.PC = 0;
        c1.T = 0;
        IR1 = 1'b0;
        IR0 = 1'b1;
        #1400 IR1 = 1'b1;
        IR0 = 1'b0;
        #3000 IR1 = 1'b1;
        IR0 = 1'b1;

        $dumpfile("mano.vcd");
        $dumpvars(0, computer_tb);
        #3600 $finish;
    end

endmodule
