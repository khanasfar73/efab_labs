module smpl_circuit_tb();
    reg A, B, C;
    wire x, y;
    smpl_circuit sc(x, y, A, B, C);
    
    initial begin
    #25
    A = 0; B = 0; C = 0;#25
    A = 0; B = 0; C = 1;#25
    A = 0; B = 1; C = 0;#25
    A = 0; B = 1; C = 1;#25
    A = 1; B = 0; C = 0;#25
    A = 1; B = 0; C = 1;#25
    A = 1; B = 1; C = 0;#25
    A = 1; B = 1; C = 1;
    end
    initial begin
        $dumpfile("smpl.vcd");
        $dumpvars(0, smpl_circuit_tb);
        #200 $finish;
    end
endmodule
