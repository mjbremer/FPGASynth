module Voice(
			input [7:0] F_in,
			input Clk, CLOCK_50, Reset, loadF, loadA, key_on, glide_en,
			input [15:0] A1, A0,
			input [1:0] shape1, shape0,
			input [15:0] A, D, S, R,
			input [23:0] glide_rate,
			output [15:0] out
);

logic [15:0] osc_out0, osc_out1, ADSR_out;
logic [15:0] osc_sum;
wire [31:0] Mult;
wire [23:0] glide_out;
wire [23:0] F_out;	

wire [23:0] osc_f_in;

assign osc_f_in = glide_en ? glide_out : F_out;

NCO  osc0(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(osc_f_in),
			.A_in(A0),
			.shape(shape0),
			.out(osc_out0),
			.key_on(key_on)
			);

NCO  osc1(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(osc_f_in),
			.A_in(A1),
			.shape(shape1),
			.out(osc_out1),
			.key_on(key_on)
			);
			
ADSR ADSR0 (.CLK(Clk),
				.RESET(Reset),
				.key_in(key_on),
				.A(A),
				.D(D),
				.S(S),
				.R(R),
				.out(ADSR_out));
				
glide g0 (.CLK(Clk),
				.RESET(Reset | ~key_on),
				.in(F_out),
				.rate(glide_rate),
				.out(glide_out));
				
			
				
rom #("notes.mem",	//this is a look up for a note with a certain frequency
		7, 24) notelookup(.Clk(CLOCK_50),
								.Reset(Reset),
								.addr(F_in[6:0]),
								.data(F_out),
								.CS(1'b1));

always_comb
	begin   //combine the outputs of each oscillator and modulate by ADSR
		osc_sum = $signed(osc_out0) + $signed(osc_out1);
		Mult = $signed(ADSR_out) * $signed(osc_sum);
		out = Mult[31:16];
	end

endmodule 