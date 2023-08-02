//dual port regfile
module regfile #(WORD = 32)
    (
        // Inputs
        data, rda, rdb, waddr, we, clk, rstn,

        // Outputs
        qa, qb
    );

    input [WORD - 1 : 0] data;      // Data to be written
    input [4:0] rda, rdb;           // Read address of port A and B
    input [4:0] waddr;              // Write address
    input we;                       // Write enable
    input clk, rstn;                // clk and active low reset

    output [WORD - 1 : 0] qa, qb;   // Output values of read ports

    // Our register file
    reg [WORD - 1 : 0] regbank [1:31];

    assign qa = (rda == 0)? 0 : regbank[rda];
    assign qb = (rdb == 0)? 0 : regbank[rdb];

    integer i;
    always @(posedge clk or negedge rstn)
    begin
        if (rstn == 1'b0)
            for (i = 1; i < 32; i = i + 1)
                regbank[i] <= 0;
        else
            if (waddr != 0 && we)
                regbank[waddr] <= data;
    end
endmodule
