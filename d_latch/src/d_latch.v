module d_latch(q,d,e); 
  input d,e;
  output q;
  reg q;
  always @ (e or d) begin
    if (e) q = d; //Same as: if (control = 1)
  end
endmodule
