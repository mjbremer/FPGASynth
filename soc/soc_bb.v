
module soc (
	amp_wire_export,
	clk_clk,
	freq_wire_export,
	led_wire_export,
	reset_reset_n,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	sr_clk,
	sw_wire_export,
	sdram_pll_clk);	

	output	[15:0]	amp_wire_export;
	input		clk_clk;
	output	[31:0]	freq_wire_export;
	output	[7:0]	led_wire_export;
	input		reset_reset_n;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[31:0]	sdram_wire_dq;
	output	[3:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	output		sr_clk;
	input	[7:0]	sw_wire_export;
	output		sdram_pll_clk;
endmodule
