module ShapeSelector
(
        input Clk, Reset,
        input [11:0] addr, // Address lines for saving data to memory
		  input [1:0] sel,
        output logic [15:0] data // Data out
);

wire [15:0] sine_out, square_out, saw_out, tri_out;

mux4_1  #(16) selector (.A(sine_out),
								.B(square_out),
								.C(saw_out),
								.D(tri_out),
								.sel(sel),
								.Out(data));

rom #("sine.mem", 12,16) sine (.Clk(Clk),
										 .Reset(Reset),
										 .CS(1'b1),
										 .addr(addr),
										 .data(sine_out));
										 
rom #("square.mem", 12,16) square (.Clk(Clk),
											  .Reset(Reset),
										     .CS(1'b1),
										     .addr(addr),
										     .data(square_out));

rom #("saw.mem", 12,16) saw (.Clk(Clk),
										 .Reset(Reset),
										 .CS(1'b1),
										 .addr(addr),
										 .data(saw_out));

rom #("triangle.mem", 12,16) triangle (.Clk(Clk),
										 .Reset(Reset),
										 .CS(1'b1),
										 .addr(addr),
										 .data(tri_out));




endmodule
