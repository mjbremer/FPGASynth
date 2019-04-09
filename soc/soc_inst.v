	soc u0 (
		.amp_wire_export  (<connected-to-amp_wire_export>),  //   amp_wire.export
		.clk_clk          (<connected-to-clk_clk>),          //        clk.clk
		.freq_wire_export (<connected-to-freq_wire_export>), //  freq_wire.export
		.led_wire_export  (<connected-to-led_wire_export>),  //   led_wire.export
		.reset_reset_n    (<connected-to-reset_reset_n>),    //      reset.reset_n
		.sdram_wire_addr  (<connected-to-sdram_wire_addr>),  // sdram_wire.addr
		.sdram_wire_ba    (<connected-to-sdram_wire_ba>),    //           .ba
		.sdram_wire_cas_n (<connected-to-sdram_wire_cas_n>), //           .cas_n
		.sdram_wire_cke   (<connected-to-sdram_wire_cke>),   //           .cke
		.sdram_wire_cs_n  (<connected-to-sdram_wire_cs_n>),  //           .cs_n
		.sdram_wire_dq    (<connected-to-sdram_wire_dq>),    //           .dq
		.sdram_wire_dqm   (<connected-to-sdram_wire_dqm>),   //           .dqm
		.sdram_wire_ras_n (<connected-to-sdram_wire_ras_n>), //           .ras_n
		.sdram_wire_we_n  (<connected-to-sdram_wire_we_n>),  //           .we_n
		.sr_clk           (<connected-to-sr_clk>),           //         sr.clk
		.sw_wire_export   (<connected-to-sw_wire_export>),   //    sw_wire.export
		.sdram_pll_clk    (<connected-to-sdram_pll_clk>)     //  sdram_pll.clk
	);

