module Autopanner (input CLOCK_50, RESET, CLK, 
		output [15:0] AUTO_PAN
		);
		
wire [11:0] addr;		
logic [15:0] sine_out;

Integrator int0 	(.Clk(CLK),
						.CLOCK_50(CLOCK_50),
						.Reset(RESET),
						.loadF(1'b1),
						.F_in(24'b0000000000001101101001111),
						.out(addr)
						);
		
rom #("sine.mem", 12,16) sine (.Clk(Clk),
										 .Reset(Reset),
										 .CS(1'b1),
										 .addr(addr),
										 .data(sine_out));
										 
										 
assign AUTO_PAN = (sine_out >>> 1) + 16'h4000; //this makes a sine wave from x7FFF to x0000	
										 
endmodule 