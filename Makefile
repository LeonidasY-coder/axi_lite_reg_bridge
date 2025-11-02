SRC = rtl/axi_lite_reg_bridge.v tb/tb_axi_lite_reg_bridge.v
OUT = tb_axi_lite_reg_bridge.vvp

all:
	iverilog -o $(OUT) $(SRC)
	vvp $(OUT)
	gtkwave tb_axi_lite_reg_bridge.vcd &

clean:
	rm -f $(OUT) *.vcd
