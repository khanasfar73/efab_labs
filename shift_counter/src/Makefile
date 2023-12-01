all:
	iverilog -o v.vvp rtl.sv rtl_tb.sv -g2012
	vvp v.vvp
	gtkwave wave.vcd

wave:
	iverilog -o v.vvp rtl.sv rtl_tb.sv -g2012
	vvp v.vvp

clean:
	rm v.vvp wave.vcd
