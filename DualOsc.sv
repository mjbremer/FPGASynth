module DualOsc(
	input Clk, CLOCK_50, Reset, loadF, loadA, key_on,
	input [23:0] F_in,
	input [15:0] A_in1, A_in0,
	input [1:0] shape1, shape0,
	output [15:0] out1, out0
			);
			
			
logic [11:0] addr;

Integrator int0 (
			.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			.loadF(1'b1),
			.F_in(F_in),
			.out(addr)
			);
			
DualShapeSelector ss(
							.Clk(Clk),
							.Reset(Reset),
							.addr(addr),
							.sel1(shape1),
							.sel0(shape0),
							.data1(rom_out1),
							.data0(rom_out0)
							);

							
wire [31:0] Mult1, Mult0;
logic [15:0] rom_out1, rom_out0;

assign Mult1 = $signed(A_in1) * $signed(rom_out1);
assign out1 = Mult1[31:16];

assign Mult0 = $signed(A_in0) * $signed(rom_out0);
assign out0 = Mult0[31:16];

endmodule


