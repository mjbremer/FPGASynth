module Autopanner (input CLOCK_50, RESET, CLK, AUTO_PAN_EN,
		input [15:0] PANNER,
		output [15:0] PAN_OUT
		);
		
logic [11:0] addr;		
logic [15:0] sine_out;
logic [16:0] math;

Integrator int0 	(.Clk(CLK),
						.CLOCK_50(CLOCK_50),
						.Reset(RESET),
						.loadF(1'b1),
						.F_in(24'h000080),
						.out(addr)
						);
		
rom #("sine.mem", 12,16) sine (.Clk(CLK),
										 .Reset(RESET),
										 .CS(1'b1),
										 .addr(addr),
										 .data(sine_out));
										 
			
always_comb
begin		

	math = ($signed(sine_out) >>> 1) + 16'h4000; //this makes a sine wave from x7FFF to x0000

		case(AUTO_PAN_EN)
			1'b0: PAN_OUT = PANNER;
			1'b1:	PAN_OUT = math[15:0];
		endcase
end
										 
endmodule 