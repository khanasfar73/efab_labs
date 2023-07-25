// https://my.eng.utah.edu/~cs3710/

module mips_tb #(parameter WIDTH = 8, REGBITS = 3)();
    reg clk = 0;
    reg reset = 1;

    mips_mem #(WIDTH,REGBITS) dut(clk, reset);

    initial
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, mips_tb);
        reset <= 1;
        #22 reset <= 0;
        #3000 $finish;
    end

    always #5 clk <= ~clk;

    always@(negedge clk)
    begin
        if(dut.memwrite)
            if(dut.adr == 8'hff & dut.writedata == 8'd0)
                $display("Fibonacci Simulation was successful...");
            else
            begin
                $display("Fibonacci Simulation failed...");
                $display("Data at address FF should be 0D");
            end
    end
endmodule


module mips_mem #(parameter WIDTH = 8, REGBITS = 3)(clk, reset);
    input clk, reset;
    wire memread,memwrite;
    wire [WIDTH-1:0] adr, writedata;
    wire [WIDTH-1:0] memdata;
    wire en =1;
    mips # (WIDTH, REGBITS) mips(clk, reset, memdata, memread, memwrite, adr, writedata);
    exmem #(WIDTH) exmem(clk, en, memwrite, adr, writedata, memdata);
endmodule


module exmem #(parameter WIDTH = 8, RAM_ADDR_BITS = 8)
    (input clk, en, memwrite, input [RAM_ADDR_BITS-1:0] adr, input [WIDTH-1:0] writedata, output reg [WIDTH-1:0] memdata);
    reg [WIDTH-1:0] mips_ram [(2**RAM_ADDR_BITS)-1:0];
    initial
        $readmemh("fib.dat", mips_ram);
    always @(negedge clk)
        if (en)
        begin
            if (memwrite)
                mips_ram[adr] <= writedata;
            memdata <= mips_ram[adr];
        end
endmodule
