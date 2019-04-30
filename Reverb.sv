module reverb (
					input logic Clk, Reset, Enable,
					input logic [15:0] in,
					output logic [15:0] out,
					input logic [15:0] feedback,
					input logic [31:0] looptime
			);
			
reg [15:0] memory [0:960];



logic [15:0] data, new_data;

logic [31:0] mult;
//assign mult = data * feedback;
//
//assign new_data = in + mult[31:16];


always_comb begin
if (Enable)
	out = new_data;
else
	out = in;
end

integer i;

always_ff @(posedge Clk) begin
	//memory[12'h025] <= 16'hDEAD;
    // Place data from RAM
	 if (Reset)
	 begin
		data = {16{1'bx}};
		i = 0;
	 end
	 else begin

		mult = ($signed(data)+$signed(in)) * $signed(feedback);
		new_data = mult[31:16];
		memory[i] = new_data;
		i = (i + 1) % looptime;
		data = memory[i];
	 end
end        
endmodule

