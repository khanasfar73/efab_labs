// Shift an N-bit counters value through a 1 bit port. The counter shall stay preserved.
// TODO: Write formal properties

module sender #(parameter BITS = 5) (
    input logic clk, rstn,
    output logic y
);
    logic [BITS-1:0] shift_counter;
    logic [$clog2(BITS)-1:0] modn;

    assign y = shift_counter[0];

    always_ff @(posedge clk or negedge rstn) begin : state_logic
        if (rstn == 0) shift_counter <= 0;
        else begin
            if (modn == 0) shift_counter <= shift_counter + 1'b1;
            else shift_counter <= {shift_counter[0], shift_counter[BITS-1:1]};
        end
    end

    always_ff @(posedge clk or negedge rstn) begin : mod_counter
        if (rstn == 0) modn <= 0;
        else
            if (modn == BITS) modn <= 0;
            else modn <= modn + 1'b1;
    end
endmodule

module catcher #(parameter BITS = 5)
(
    input logic clk, rstn, y,
    output logic [BITS-1:0] c
);
    logic [BITS-1:0] tmp;

    always_ff @(posedge clk or negedge rstn) begin : sipo
        if (rstn == 0) tmp <= 0;
        else 
            tmp <= {y, tmp[BITS-1:1]};
    end

    assign c = tmp;
endmodule


module rtl #(parameter BITS = 5)
(
    input logic clk, rstn, 
    output logic [BITS-1:0] c
);
    logic y;
    sender #(.BITS(BITS)) send(clk ,rstn, y);
    catcher #(.BITS(BITS)) catch(clk, rstn, y, c);
endmodule
