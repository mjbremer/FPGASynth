module NCO (
	input Clk, CLOCK_50, Reset, loadF, loadA, key_on,
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

rom #("sine.mem",
		12,16) sine(.Clk(CLOCK_50), .Reset(Reset||key_on), .addr(Phase_out[23:12]), .data(rom_out));
//assign rom_out = 16'hFFFF;
//dual_port_rom sine(.clk(CLOCK_50),.addr_a(Phase_out[23:12]), .q_a(rom_out));

register #(24) F(.Clk(Clk), .Reset(Reset||key_on), .Load(loadF), .D(F_in), .Q(F_out));
register #(24) Phase(.Clk(Clk), .Reset(Reset||key_on), .Load(1'b1), .D(Acc), .Q(Phase_out));
register #(16) Amp(.Clk(Clk), .Reset(Reset||key_on), .Load(loadA), .D(A_in), .Q(Amp_out));

assign Mult = Amp_out * rom_out;
assign out = key_on ? Mult[31:16] : 16'b0;

	
endmodule
