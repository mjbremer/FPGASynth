module(input CLOCK_50, RESET, CLK, 
		input [15:0] LDATA, RDATA,
		output [15:0] PAN_LDATA, PAN_RDATA
		);
		
wire [11:0] addr;		
logic [15:0] sine_out;
logic [31:0] MULTLEFT, MULTRIGHT;

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
										 
assign MULTLEFT = $signed(sine_out) * $signed(LDATA);
assign MULTRIGHT = $signed(sine_out) * $signed(RDATA);

assign PAN_LDATA = MULTLEFT[31:16];
assign PAN_RDATA = MULTRIGHT[31:16];	
										 
endmodule 