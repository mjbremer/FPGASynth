module Voice(
			input [6:0] F_in,
			input Clk, CLOCK_50, Reset, loadF, loadA, key_on, glide_en,
			input [15:0] A1, A0,
			input [1:0] shape1, shape0,
			input [15:0] A, D, S, R,
			input [23:0] glide_rate,
			output [15:0] out
);

logic [15:0] osc_out0, osc_out1, ADSR_out, ADSR_smooth;
logic [15:0] osc_sum;
logic [15:0] A1_smooth, A0_smooth;
wire [31:0] Mult;
wire [23:0] glide_out;
wire [23:0] F_out;	

wire [23:0] osc_f_in;

assign osc_f_in = glide_en ? glide_out : F_out;

//NCO  osc0(.Clk(Clk),
//			.CLOCK_50(CLOCK_50),
//			.Reset(Reset),
//			.loadF(1'b1),
//			.loadA(1'b1),
//			.F_in(osc_f_in),
//			.A_in(A0_smooth),
//			.shape(shape0),
//			.out(osc_out0),
//			.key_on(key_on)
//			);
//
//NCO  osc1(.Clk(Clk),
//			.CLOCK_50(CLOCK_50),
//			.Reset(Reset),
//			.loadF(1'b1),
//			.loadA(1'b1),
//			.F_in(osc_f_in),
//			.A_in(A1_smooth),
//			.shape(shape1),
//			.out(osc_out1),
//			.key_on(key_on)
//			);
			
DualOsc osc(.Clk(Clk),
			.CLOCK_50(CLOCK_50),
			.Reset(Reset),
			
			.loadF(1'b1),
			.loadA(1'b1),
			.F_in(osc_f_in),
			.A_in1(A1_smooth),
			.A_in0(A0_smooth),
			.shape1(shape1),
			.shape0(shape0),
			.out1(osc_out1),
			.out0(osc_out0)
			);
			
ADSR ADSR0 (.CLK(Clk),
				.RESET(Reset),
				.key_in(key_on),
				.A(A),
				.D(D),
				.S(S),
				.R(R),
				.out(ADSR_out));
				
glide #(24) g0 (.CLK(Clk),
				.RESET(Reset | ~key_on),
				.in(F_out),
				.rate(glide_rate),
				.out(glide_out));
				
glide #(16) ampsmoother (.CLK(Clk),
				.RESET(Reset),
				.in(ADSR_out),
				.rate(16'h0088),
				.out(ADSR_smooth));
				
glide #(16) a1smoother (.CLK(Clk),
				.RESET(Reset),
				.in(A1),
				.rate(16'h0088),
				.out(A1_smooth));
				
glide #(16) a0smoother (.CLK(Clk),
				.RESET(Reset),
				.in(A0),
				.rate(16'h0088),
				.out(A0_smooth));
			
				
rom #("notes.mem",	//this is a look up for a note with a certain frequency
		7, 24) notelookup(.Clk(CLOCK_50),
								.Reset(Reset),
								.addr(F_in),
								.data(F_out),
								.CS(1'b1));

always_comb
	begin   //combine the outputs of each oscillator and modulate by ADSR
		osc_sum = $signed(osc_out0) + $signed(osc_out1);
		Mult = $signed(ADSR_smooth) * $signed(osc_sum);
		out = Mult[31:16];
	end

endmodule 