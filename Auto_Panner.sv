//module(input CLOCK_50, RESET, CLK, 
//		output [15:0] LDATA, RDATA
//		);
//		
//Integrator int0 	(.Clk(),
//						.CLOCK_50(),
//						.Reset(),
//						.loadF(),
//						.F_in(),
//						.out()
//						);
//		
//rom #("sine.mem", 12,16) sine (.Clk(Clk),
//										 .Reset(Reset),
//										 .CS(1'b1),
//										 .addr(12'b),
//										 .data(sine_out));
//										 
//
//										 
//endmodule 