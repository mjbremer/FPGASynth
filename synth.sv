module synth (

output AUD_XCK,  AUD_DACDAT, I2C_SDAT, I2C_SCLK,
output [8:0] LEDG,
output [17:0] LEDR,
input AUD_BCLK, AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, CLOCK_50,
input [3:0] KEY, input [17:0] SW,
output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
);

logic [15:0] LDATA, RDATA;

logic Clk, INIT, INIT_FINISH, adc_full, data_over;


logic [31:0] ADCDATA;


wire [7:0] Frequency;
wire [15:0] Amp;
wire [15:0] A,D,S,R;
wire [23:0] Frequency2;
wire [7:0] key_on, shape;
wire [15:0] osc_out;
wire reset_ah;
assign reset_ah = ~KEY[3]; // USE LAST KEY AS RESET


Initializer init(.INIT(INIT), .INIT_FINISH(INIT_FINISH), .Clk(CLOCK_50), .Reset(reset_ah));

//NCO  osc0(.Clk(AUD_DACLRCK),
//			.CLOCK_50(CLOCK_50),
//			.Reset(reset_ah),
//			.loadF(1'b1),
//			.loadA(1'b1),
//			.F_in(Frequency2),
//			.A_in(Amp),
//			.shape(shape[1:0]),
//			.out(osc_out),
//			.key_on(key_on[0]),
//			.A(A), .D(D), .S(S), .R(R),
//			);

Voice voice0(
			.F_in(Frequency2),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(key_on[0]), 
			.A_in(Amp),
			.shape(shape[1:0]),
			.A(A), 
			.D(D), 
			.S(S), 
			.R(R),
			.out(osc_out)
			);
			
rom #("notes.mem",
		7, 24) notelookup(.Clk(CLOCK_50),
								.Reset(reset_ah),
								.addr(Frequency[6:0]),
								.data(Frequency2),
								.CS(1'b1));
//24'b000000100101100010111111

//always_ff @ (negedge data_over) begin
//	LDATA <= osc_out;
//	RDATA <= osc_out;
//end

	assign LDATA = osc_out;
	assign RDATA = osc_out;
	
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(CLOCK_50),
                            .Reset(reset_ah),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );

soc soc0(.clk_clk(CLOCK_50),
			.sr_clk(Clk),
			.reset_reset_n(KEY[3]),
			.freq_wire_export(Frequency),
			.key_on_export(key_on),
			.amp_wire_export(Amp),
			.shape_wire_export(shape),
			.attack_export(A),
			.decay_export(D),
			.sustain_export(S),
			.release0_export(R),
			.sdram_wire_addr(DRAM_ADDR),    
			.sdram_wire_ba(DRAM_BA),      	//  .ba
			.sdram_wire_cas_n(DRAM_CAS_N),    //  .cas_n
			.sdram_wire_cke(DRAM_CKE),     	//  .cke
			.sdram_wire_cs_n(DRAM_CS_N),      //  .cs_n
			.sdram_wire_dq(DRAM_DQ),      	//  .dq
			.sdram_wire_dqm(DRAM_DQM),     	//  .dqm
			.sdram_wire_ras_n(DRAM_RAS_N),    //  .ras_n
			.sdram_wire_we_n(DRAM_WE_N),      //  .we_n
			.sdram_clk_clk(DRAM_CLK),			//  clock out to SDRAM from other PLL port);
			
			                    .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset));
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

HexDriver hex_driver7 (Amp[15:12], HEX7);
HexDriver hex_driver6 (Amp[11:8], HEX6);
HexDriver hex_driver5 (Amp[7:4], HEX5);
HexDriver hex_driver4 (Amp[3:0], HEX4);
HexDriver hex_driver3 (Frequency[7:4], HEX3);
HexDriver hex_driver2 (Frequency[3:0], HEX2);
HexDriver hex_driver1 (key_on[7:4], HEX1);
HexDriver hex_driver0 (key_on[3:0], HEX0);
     

endmodule

