
timeunit 1ns; timeprecision 1ns;

module adder(a, b, y);
    input logic [3:0] a, b;
    outut logic [4:0] y;

    always_comb begin
        y = a +b;
    end
endmodule: adder

interface adder_if;
    logic [3:0] a, b;
    logic [4:0] y;
endinterface