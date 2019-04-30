module Autopanner (input CLOCK_50, RESET, CLK, AUTO_PAN_EN,
		input [15:0] PANNER, PAN_DEPTH,
		output [15:0] PAN_OUT
		);
		
logic [11:0] addr;		
logic [15:0] sine_out;
logic [31:0] math;

Integrator int0 	(.Clk(CLK),
						.CLOCK_50(CLOCK_50),
						.Reset(RESET),
						.loadF(1'b1),
						.F_in(PANNER),
						.out(addr)
						);
		
rom #("sine.mem", 12,16) sine (.Clk(CLK),
										 .Reset(RESET),
										 .CS(1'b1),
										 .addr(addr),
										 .data(sine_out));
		
//24'h000080



			
always_comb
begin		

	math = ($signed(PAN_DEPTH))*$signed($signed(sine_out) >>> 1); //this makes a sine wave from x7FFF to x0000

		case(AUTO_PAN_EN)
			1'b0: PAN_OUT = 16'h4000;
			1'b1:	PAN_OUT = math[31:16] + 16'h4000;
		endcase
end
										 
endmodule 