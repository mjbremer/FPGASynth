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

logic INIT, INIT_FINISH, adc_full, data_over, AUTO_PAN_EN;


logic [31:0] ADCDATA;


logic [15:0]ATTACK,RLEASE,SUSTAIN,DECAY;
logic [1:0] SHAPE1,SHAPE0;
logic ARP_EN, GLIDE_EN;
logic [15:0] ARP_TIME;
logic [23:0] GLIDE_RATE;
logic PingPongEn;


logic [6:0] FREQ0, FREQ1, FREQ2, FREQ3;
logic [15:0] AMP1_0, AMP0_0, AMP1_1, AMP0_1, AMP1_2, AMP0_2, AMP1_3, AMP0_3;
logic KEY3, KEY2, KEY1, KEY0;
logic ARP3, ARP2, ARP1, ARP0;
logic [31:0] MultL, MultR;


logic [6:0] FREQ4, FREQ5, FREQ6, FREQ7;
logic [15:0] AMP1_4, AMP0_4, AMP1_5, AMP0_5, AMP1_6, AMP0_6, AMP1_7, AMP0_7;
logic KEY4, KEY5, KEY6, KEY7;
logic ARP7, ARP6, ARP5, ARP4;


logic FILTER_EN;
logic [15:0] FILTER_A0, FILTER_A1, FILTER_A2, FILTER_B0, FILTER_B1, FILTER_B2;


logic DELAY_EN;
logic [15:0] DELAY_FEEDBACK;
logic [31:0] DELAY_TIME;
	

assign LEDG[0] = ARP7;
assign LEDG[1] = ARP6;
assign LEDG[2] = ARP5;
assign LEDG[3] = ARP4;
assign LEDG[4] = ARP3;
assign LEDG[5] = ARP2;
assign LEDG[6] = ARP1;
assign LEDG[7] = ARP0;

wire [15:0] osc_out, osc_out0, osc_out1, osc_out2, osc_out3, osc_out4, osc_out5, osc_out6, osc_out7;
logic [15:0] osc_sum, PANNING, PAN_OUT;
wire reset_ah;
assign reset_ah = ~KEY[3]; // USE LAST KEY AS RESET


Initializer init(.INIT(INIT), .INIT_FINISH(INIT_FINISH), .Clk(CLOCK_50), .Reset(reset_ah));



Arpeggiator arp0(
						.key0(KEY0),
						.key1(KEY1),
						.key2(KEY2),
						.key3(KEY3),
						.key4(KEY4),
						.key5(KEY5),
						.key6(KEY6),
						.key7(KEY7),
						.CLK(AUD_DACLRCK),
						.RESET(reset_ah),
						.Enable(ARP_EN),
						.PingPongEn(PingPongEn),
						.countermax(ARP_TIME),
						.out0(ARP0),
						.out1(ARP1),
						.out2(ARP2),
						.out3(ARP3),
						.out4(ARP4),
						.out5(ARP5),
						.out6(ARP6),
						.out7(ARP7));

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
			
Voice voice4(
			.F_in(FREQ4),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP4), 
			.A1(AMP1_4),
			.A0(AMP0_4),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out4),
			.glide_en(1'b0)
				);
Voice voice5(
			.F_in(FREQ5),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP5), 
			.A1(AMP1_5),
			.A0(AMP0_5),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out5),
			.glide_en(1'b0)
				);
Voice voice6(
			.F_in(FREQ3),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP6), 
			.A1(AMP1_6),
			.A0(AMP0_6),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out6),
			.glide_en(1'b0)
				);	
Voice voice7(
			.F_in(FREQ7),
			.Clk(AUD_DACLRCK), 
			.CLOCK_50(CLOCK_50), 
			.Reset(reset_ah), 
			.loadF(1'b1), 
			.loadA(1'b1), 
			.key_on(ARP7), 
			.A1(AMP1_7),
			.A0(AMP0_7),
			.shape1(SHAPE1),
			.shape0(SHAPE0),
			.A(ATTACK), 
			.D(DECAY), 
			.S(SUSTAIN), 
			.R(RLEASE),
			.out(osc_out7),
			.glide_en(1'b0)
				);
				
Autopanner auto0	(.CLOCK_50(CLOCK_50),
						.RESET(reset_ah),
						.AUTO_PAN_EN(AUTO_PAN_EN),
						.CLK(AUD_DACLRCK),
						.PANNER(PANNING),
						.PAN_OUT(PAN_OUT)
		);
			
			
always_comb
	begin
		osc_sum = osc_out0 + osc_out1 + osc_out2 + osc_out3 + osc_out4 + osc_out5 + osc_out6 + osc_out7;
		osc_out = osc_sum;
	end
			

//	assign MultL = filter_out * (16'h7FFF - PAN_OUT);
//	assign MultR = filter_out * PAN_OUT;
	assign LDATA = filter_out1;//MultL[31:16];
	assign RDATA = filter_out1;//MultR[31:16];
	
	logic [15:0] delay_out;
	
	delay d0(
				.Clk(AUD_DACLRCK),
				.Reset(reset_ah),
				.Enable(DELAY_EN),
				.in(osc_out),
				.out(delay_out),
				.feedback(DELAY_FEEDBACK),
				.looptime(DELAY_TIME)
				);
				

	
	logic [15:0] filter_out1, filter_out2, filter_out3;
	
	filter filter0 (
						.Clk(AUD_DACLRCK),
						.Reset(reset_ah),
						.Enable(FILTER_EN),
						.x(delay_out),
						.y(filter_out1),
						.b0(FILTER_B0),
						.b2(FILTER_B2),
						.b1(FILTER_B1),
						.a0(FILTER_A0),
						.a1(FILTER_A1),
						.a2(FILTER_A2)
						);
						
//	filter filter1 (
//						.Clk(AUD_DACLRCK),
//						.Reset(reset_ah),
//						.Enable(FILTER_EN),
//						.x(filter_out1),
//						.y(filter_out2),
//						.b0(FILTER_B0),
//						.b2(FILTER_B2),
//						.b1(FILTER_B1),
//						.a0(FILTER_A0),
//						.a1(FILTER_A1),
//						.a2(FILTER_A2)
//						);
//	filter filter2 (
//						.Clk(AUD_DACLRCK),
//						.Reset(reset_ah),
//						.Enable(FILTER_EN),
//						.x(filter_out2),
//						.y(filter_out3),
//						.b0(FILTER_B0),
//						.b2(FILTER_B2),
//						.b1(FILTER_B1),
//						.a0(FILTER_A0),
//						.a1(FILTER_A1),
//						.a2(FILTER_A2)
//						);
//						
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
		.amp0_4_amp0_4(AMP0_4),          //          amp0_0.amp0_0
		.amp0_5_amp0_5(AMP0_5),          //          amp0_1.amp0_1
		.amp0_6_amp0_6(AMP0_6),          //          amp0_2.amp0_2
		.amp0_7_amp0_7(AMP0_7),          //          amp0_3.amp0_3
		.amp1_4_amp1_4(AMP1_4),          //          amp1_0.amp1_0
		.amp1_5_amp1_5(AMP1_5),          //          amp1_1.amp1_1
		.amp1_6_amp1_6(AMP1_6),          //          amp1_2.amp1_2
		.amp1_7_amp1_7(AMP1_7),          //          amp1_3.amp1_3
		.freq4_freq4(FREQ4),            //           freq0.freq0
		.freq5_freq5(FREQ5),            //           freq1.freq1
		.freq6_freq6(FREQ6),            //           freq2.freq2
		.freq7_freq7(FREQ7),            //           freq3.freq3
		.key4_key4(KEY4),              //            key0.key0
		.key5_key5(KEY5),              //            key1.key1
		.key6_key6(KEY6),              //            key2.key2
		.key7_key7(KEY7),              //            key3.key3
		.r_rlease(RLEASE),               //               r.rlease
		.s_sustain(SUSTAIN),              //               s.sustain
		.shape0_shape0(SHAPE0),          //          shape0.shape0
		.shape1_shape1(SHAPE1),           //          shape1.shape1
		.glide_en_glide_en(GLIDE_EN),
		.glide_rate_glide_rate(GLIDE_RATE),
		.arp_en_arp_en(ARP_EN),
		.arp_time_arp_time(ARP_TIME),
		.pingpongen_pingpongen(PingPongEn),
		.panning_panning(PANNING),
		.auto_pan_en_auto_pan_en(AUTO_PAN_EN),
		.filter_en_filter_en(FILTER_EN),
		.filter_a0_filter_a0(FILTER_A0),
		.filter_a1_filter_a1(FILTER_A1),
		.filter_a2_filter_a2(FILTER_A2),
		.filter_b0_filter_b0(FILTER_B0),
		.filter_b1_filter_b1(FILTER_B1),
		.filter_b2_filter_b2(FILTER_B2),
		.delay_en_delay_en(DELAY_EN),
		.delay_feedback_delay_feedback(DELAY_FEEDBACK),
		.delay_time_delay_time(DELAY_TIME)
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

