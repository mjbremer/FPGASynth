module NCO (
	input Clk, CLOCK_50, Reset, loadF, loadA, key_on,
	input [23:0] F_in,
	input [15:0] A_in,
	input [1:0] shape,
	output [15:0] out
	);
	

wire [15:0] Amp_out;
wire [23:0] F_out, Phase_out;
wire [23:0] Acc;
wire [31:0] Mult;
logic [15:0] rom_out;

assign Acc = F_out + Phase_out;

//rom #("sine.mem",
//		12,16) sine(.Clk(CLOCK_50), .Reset(Reset), .CS(1'b1), .addr(Phase_out[23:12]), .data(rom_out));
ShapeSelector ss0 (.Clk(Clk),
						 .Reset(Reset),
						 .addr(Phase_out[23:12]),
						 .data(rom_out),
						 .sel(shape));


register #(24) F(.Clk(Clk), .Reset(Reset), .Load(loadF), .D(F_in), .Q(F_out));
register #(24) Phase(.Clk(Clk), .Reset(Reset), .Load(key_on), .D(Acc), .Q(Phase_out));
register #(16) Amp(.Clk(Clk), .Reset(Reset), .Load(loadA), .D(A_in), .Q(Amp_out));

assign Mult = $signed(Amp_out) * $signed(rom_out);
assign out = Mult[31:16]; //  (key_on == 1'b1) ? Mult[31:16] : 16'b0;

	
endmodule
