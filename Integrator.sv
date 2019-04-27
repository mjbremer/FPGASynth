module Integrator (
	input Clk, CLOCK_50, Reset, loadF,
	input [23:0] F_in,
	output [11:0] out
	);
	

wire [23:0] F_out, Phase_out;
wire [23:0] Acc;

assign Acc = F_out + Phase_out;

register #(24) F(.Clk(Clk), .Reset(Reset), .Load(loadF), .D(F_in), .Q(F_out));
register #(24) Phase(.Clk(Clk), .Reset(Reset), .Load(1'b1), .D(Acc), .Q(Phase_out));

assign out = Phase_out[23:12];


endmodule
