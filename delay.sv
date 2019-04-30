module delay (
					input logic Clk, Reset, Enable,
					input logic [15:0] in,
					output logic [15:0] out,
					input logic [15:0] feedback,
					input logic [31:0] looptime
			);
			
reg [15:0] memory [0:48000];



logic [15:0] data, new_data;

logic [31:0] mult;
assign mult = data * feedback;

assign new_data = in + mult[31:16];

assign out = new_data;
integer i;

always @(posedge Clk) begin
	//memory[12'h025] <= 16'hDEAD;
    // Place data from RAM
	 if (Reset)
	 begin
		data = {16{1'bx}};
		i = 0;
	 end
	 else begin
		data = memory[i];
		memory[i] = new_data;
		i = (i + 1) % looptime;
	 end
end        
endmodule

