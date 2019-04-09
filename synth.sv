module synth (

output AUD_XCK,  AUD_DACDAT, I2C_SDAT, I2C_SCLK,
output [8:0] LEDG,
output [17:0] LEDR,
input AUD_BCLK, AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, CLOCK_50,
input [3:0] KEY, input [17:0] SW,
output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
					  output [12:0] DRAM_ADDR,
					  output [1:0]  DRAM_BA,
					  output        DRAM_CAS_N,
					  output		    DRAM_CKE,
					  output		    DRAM_CS_N,
					  inout  [31:0] DRAM_DQ,
					  output  [3:0] DRAM_DQM,
					  output		    DRAM_RAS_N,
					  output		    DRAM_WE_N,
					  output		    DRAM_CLK
);

logic [15:0] LDATA, RDATA;

logic Clk, INIT, INIT_FINISH, adc_full, data_over;


logic [31:0] ADCDATA;


logic [23:0] Frequency, Frequency2;
wire [15:0] osc_out;
logic reset_ah;
assign reset_ah = ~KEY[3]; // USE LAST KEY AS RESET


Initializer init(.INIT(INIT), .INIT_FINISH(INIT_FINISH), .Clk(CLOCK_50), .Reset(reset_ah));

NCO  osc0(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(reset_ah),
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(Frequency2),
			.A_in({SW[17:10], 8'b0}),
			.out(osc_out)
			);
			
rom #("D:\\yuh\\ece-385\\synth\\notes.mem",
		7, 24) notelookup(.Clk(CLOCK_50),
								.Reset(reset_ah),
								.addr(SW[6:0]),
								.data(Frequency2));
//24'b000000100101100010111111

assign LDATA = osc_out;
assign RDATA = osc_out;

soc soc0(.clk_clk(CLOCK_50),
			.sr_clk(Clk),
			.reset_reset_n(reset_ah),
			.freq_wire_export(Frequency),
			.led_wire_export(LEDG),
			.sw_wire_export(SW[7:0]),
			.sdram_wire_addr(DRAM_ADDR),    
			.sdram_wire_ba(DRAM_BA),      	//  .ba
			.sdram_wire_cas_n(DRAM_CAS_N),    //  .cas_n
			.sdram_wire_cke(DRAM_CKE),     	//  .cke
			.sdram_wire_cs_n(DRAM_CS_N),      //  .cs_n
			.sdram_wire_dq(DRAM_DQ),      	//  .dq
			.sdram_wire_dqm(DRAM_DQM),     	//  .dqm
			.sdram_wire_ras_n(DRAM_RAS_N),    //  .ras_n
			.sdram_wire_we_n(DRAM_WE_N),      //  .we_n
			.sdram_pll_clk(DRAM_CLK)			//  clock out to SDRAM from other PLL port);
			);
//assign Clk = KEY[0]; // DEBUG CLOCK


audio_interface ai0(.LDATA(LDATA),
						   .RDATA(RDATA),
							.Clk(CLOCK_50),
							.Reset(reset_ah),
							.INIT(INIT),
							.INIT_FINISH(INIT_FINISH),
							.adc_full(adc_full),
							.data_over(data_over),
							.AUD_MCLK(AUD_XCK),
							.AUD_BCLK(AUD_BCLK),
							.AUD_ADCDAT(AUD_ADCDAT),
							.AUD_DACDAT(AUD_DACDAT),
							.AUD_DACLRCK(AUD_DACLRCK),
							.AUD_ADCLRCK(AUD_ADCLRCK),
							.I2C_SDAT(I2C_SDAT),
							.I2C_SCLK(I2C_SCLK),
							.ADCDATA(ADCDATA)
							);

HexDriver hex_driver7 (osc_out[15:12], HEX7);
HexDriver hex_driver6 (osc_out[11:8], HEX6);
HexDriver hex_driver5 (osc_out[7:4], HEX5);
HexDriver hex_driver4 (osc_out[3:0], HEX4);

endmodule

