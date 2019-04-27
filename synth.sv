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

logic INIT, INIT_FINISH, adc_full, data_over;


logic [31:0] ADCDATA;


logic [15:0]ATTACK,RLEASE,SUSTAIN,DECAY;
logic [1:0] SHAPE1,SHAPE0;
logic ARP_EN, GLIDE_EN;
logic [15:0] ARP_TIME;
logic [23:0] GLIDE_RATE;
logic [6:0] FREQ0, FREQ1, FREQ2, FREQ3;
logic [15:0] AMP1_0, AMP0_0, AMP1_1, AMP0_1, AMP1_2, AMP0_2, AMP1_3, AMP0_3;
logic KEY3, KEY2, KEY1, KEY0;
logic ARP3, ARP2, ARP1, ARP0;
logic PingPongEn;

assign LEDG[0] = ARP3;
assign LEDG[1] = ARP2;
assign LEDG[2] = ARP1;
assign LEDG[3] = ARP0;

wire [15:0] osc_out, osc_out0, osc_out1, osc_out2, osc_out3; //osc_out4, osc_out5, osc_out6, osc_out7;
logic [15:0] osc_sum;
wire reset_ah;
assign reset_ah = ~KEY[3]; // USE LAST KEY AS RESET


Initializer init(.INIT(INIT), .INIT_FINISH(INIT_FINISH), .Clk(CLOCK_50), .Reset(reset_ah));


Arpeggiator arp0(
						.key0(KEY0),
						.key1(KEY1),
						.key2(KEY2),
						.key3(KEY3),
						.CLK(AUD_DACLRCK),
						.RESET(reset_ah),
						.Enable(ARP_EN),
						.PingPongEn(PingPongEn),
						.countermax(ARP_TIME),
						.out0(ARP0),
						.out1(ARP1),
						.out2(ARP2),
						.out3(ARP3));

Voice voice0(
			.F_in(FREQ0),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP0), 
			.A1(AMP1_0),
			.A0(AMP0_0),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out0),
			.glide_en(GLIDE_EN),
			.glide_rate(GLIDE_RATE)
			);
			
Voice voice1(
			.F_in(FREQ1),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP1), 
			.A1(AMP1_1),
			.A0(AMP0_1),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out1),
			.glide_en(1'b0)
			);
			
Voice voice2(
			.F_in(FREQ2),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP2), 
			.A1(AMP1_2),
			.A0(AMP0_2),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out2),
			.glide_en(1'b0)
			);
			
Voice voice3(
			.F_in(FREQ3),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP3), 
			.A1(AMP1_3),
			.A0(AMP0_3),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out3),
			.glide_en(1'b0)
			);
			
//Voice voice4(
//			.F_in(FREQ3),
//			.Clk(AUD_DACLRCK), 
//			.CLOCK_50(CLOCK_50), 
//			.Reset(reset_ah), 
//			.loadF(1'b1), 
//			.loadA(1'b1), 
//			.key_on(ARP3), 
//			.A1(AMP1_3),
//			.A0(AMP0_3),
//			.shape1(SHAPE1),
//			.shape0(SHAPE0),
//			.A(ATTACK), 
//			.D(DECAY), 
//			.S(SUSTAIN), 
//			.R(RLEASE),
//			.out(LEDR[0]),
//			.glide_en(1'b0)
//				);
//Voice voice5(
//			.F_in(FREQ3),
//			.Clk(AUD_DACLRCK), 
//			.CLOCK_50(CLOCK_50), 
//			.Reset(reset_ah), 
//			.loadF(1'b1), 
//			.loadA(1'b1), 
//			.key_on(ARP3), 
//			.A1(AMP1_3),
//			.A0(AMP0_3),
//			.shape1(SHAPE1),
//			.shape0(SHAPE0),
//			.A(ATTACK), 
//			.D(DECAY), 
//			.S(SUSTAIN), 
//			.R(RLEASE),
//			.out(LEDR[1]),
//			.glide_en(1'b0)
//				);
//Voice voice6(
//			.F_in(FREQ3),
//			.Clk(AUD_DACLRCK), 
//			.CLOCK_50(CLOCK_50), 
//			.Reset(reset_ah), 
//			.loadF(1'b1), 
//			.loadA(1'b1), 
//			.key_on(ARP3), 
//			.A1(AMP1_3),
//			.A0(AMP0_3),
//			.shape1(SHAPE1),
//			.shape0(SHAPE0),
//			.A(ATTACK), 
//			.D(DECAY), 
//			.S(SUSTAIN), 
//			.R(RLEASE),
//			.out(LEDR[2]),
//			.glide_en(1'b0)
//				);	
//Voice voice7(
//			.F_in(FREQ3),
//			.Clk(AUD_DACLRCK), 
//			.CLOCK_50(CLOCK_50), 
//			.Reset(reset_ah), 
//			.loadF(1'b1), 
//			.loadA(1'b1), 
//			.key_on(ARP3), 
//			.A1(AMP1_3),
//			.A0(AMP0_3),
//			.shape1(SHAPE1),
//			.shape0(SHAPE0),
//			.A(ATTACK), 
//			.D(DECAY), 
//			.S(SUSTAIN), 
//			.R(RLEASE),
//			.out(LEDR[3]),
//			.glide_en(1'b0)
//				);
//			
			
always_comb
	begin
		osc_sum = osc_out0 + osc_out1 + osc_out2 + osc_out3; //+ osc_out4 + osc_out5 + osc_out6 + osc_out7;
		osc_out = osc_sum;
	end
			

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
		.reset_reset_n(KEY[3]),
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
		.otg_hpi_reset_export(hpi_reset),
		.a_attack(ATTACK),               //               a.attack
		.amp0_0_amp0_0(AMP0_0),          //          amp0_0.amp0_0
		.amp0_1_amp0_1(AMP0_1),          //          amp0_1.amp0_1
		.amp0_2_amp0_2(AMP0_2),          //          amp0_2.amp0_2
		.amp0_3_amp0_3(AMP0_3),          //          amp0_3.amp0_3
		.amp1_0_amp1_0(AMP1_0),          //          amp1_0.amp1_0
		.amp1_1_amp1_1(AMP1_1),          //          amp1_1.amp1_1
		.amp1_2_amp1_2(AMP1_2),          //          amp1_2.amp1_2
		.amp1_3_amp1_3(AMP1_3),          //          amp1_3.amp1_3
		.d_decay(DECAY),                //               d.decay
		.freq0_freq0(FREQ0),            //           freq0.freq0
		.freq1_freq1(FREQ1),            //           freq1.freq1
		.freq2_freq2(FREQ2),            //           freq2.freq2
		.freq3_freq3(FREQ3),            //           freq3.freq3
		.key0_key0(KEY0),              //            key0.key0
		.key1_key1(KEY1),              //            key1.key1
		.key2_key2(KEY2),              //            key2.key2
		.key3_key3(KEY3),              //            key3.key3
		.r_rlease(RLEASE),               //               r.rlease
		.s_sustain(SUSTAIN),              //               s.sustain
		.shape0_shape0(SHAPE0),          //          shape0.shape0
		.shape1_shape1(SHAPE1),           //          shape1.shape1
		.glide_en_glide_en(GLIDE_EN),
		.glide_rate_glide_rate(GLIDE_RATE),
		.arp_en_arp_en(ARP_EN),
		.arp_time_arp_time(ARP_TIME),
		.pingpongen_new_signal(PingPongEn)
		 );

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

HexDriver hex_driver7 (AMP1_0[15:12], HEX7);
HexDriver hex_driver6 (AMP1_0[11:8], HEX6);
HexDriver hex_driver5 (AMP1_0[7:4], HEX5);
HexDriver hex_driver4 (AMP1_0[3:0], HEX4);
HexDriver hex_driver3 ({1'b0,FREQ0[6:4]}, HEX3);
HexDriver hex_driver2 (FREQ0[3:0], HEX2);
HexDriver hex_driver1 ({4{KEY0}}, HEX1);
HexDriver hex_driver0 ({4{KEY0}}, HEX0);
     

endmodule

