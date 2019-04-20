module Voice(
			input [23:0] F_in,
			input Clk, CLOCK_50, Reset, loadF, loadA, key_on,
			input [15:0] A_in,
			input [3:0] shape,
			input [15:0] A, D, S, R,
			output [15:0] out
);

logic [15:0] osc_out0, osc_out1, ADSR_out;
logic [16:0] osc_sum;
wire [31:0] Mult;

NCO  osc0(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(F_in),
			.A_in(A_in),
			.shape(shape[1:0]),
			.out(osc_out0),
			.key_on(key_on),
			);

NCO  osc1(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(F_in),
			.A_in(A_in),
			.shape(shape[3:2]),
			.out(osc_out1),
			.key_on(key_on),
			);
			
ADSR ADSR0 (.CLK(Clk),
				.RESET(Reset),
				.key_in(key_on),
				.A(A),
				.D(D),
				.S(S),
				.R(R),
				.out(ADSR_out));

always_comb
	begin
		osc_sum = $signed(osc_out0) + $signed(osc_out1);
		//osc_sum = osc_sum >>> 1;
		Mult = $signed(ADSR_out) * $signed(osc_sum[16:1]);
		out = Mult[31:16];
	end

endmodule 