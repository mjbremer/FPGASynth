module NCO (
	input Clk, CLOCK_50, Reset, loadF, loadA,
	input [23:0] F_in,
	input [15:0] A_in,
	output [15:0] out
	);
	

wire [15:0] Amp_out;
wire [23:0] F_out, Phase_out;
wire [23:0] Acc;
wire [31:0] Mult;
logic [15:0] rom_out;

assign Acc = F_out + Phase_out;

rom #("D:\\yuh\\ece-385\\synth\\sine.mem",
		12,16) sine(.Clk(CLOCK_50), .Reset(Reset), .addr(Phase_out[23:12]), .data(rom_out));
//assign rom_out = 16'hFFFF;
//dual_port_rom sine(.clk(CLOCK_50),.addr_a(Phase_out[23:12]), .q_a(rom_out));

register #(24) F(.Clk(Clk), .Reset(Reset), .Load(loadF), .D(F_in), .Q(F_out));
register #(24) Phase(.Clk(Clk), .Reset(Reset), .Load(1'b1), .D(Acc), .Q(Phase_out));
register #(16) Amp(.Clk(Clk), .Reset(Reset), .Load(loadA), .D(A_in), .Q(Amp_out));

assign Mult = Amp_out * rom_out;
assign out = Mult[31:16];

	
endmodule
