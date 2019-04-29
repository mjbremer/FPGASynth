module filter (
					input logic Clk, Reset, Enable,
					input logic [15:0] x, a0, a1, a2, b0, b1, b2,
					output logic [15:0] y
					);


					
reg [15:0] x1,x2, y0,y1,y2;


logic [31:0] b0x0, b1x1, b2x2,a1y1, a2y2, a0y0;

assign b0x0 = b0 * x;
assign b1x1 = b1 * x1;
assign b2x2 = b2 * x2;
assign a0y0 = a0 * y0;
assign a1y1 = a1 * y1;
assign a2y2 = a2 * y2;


always_comb
begin
	y0 = b0x0[31:16] + b1x1[31:16] + b2x2[31:16] + a1y1[31:16] + a2y2[31:16];
	
	y = a0y0[31:16];
end



always_ff @(posedge Clk)
begin

	y2 <= y1;
	y1 <= y;
	x2 <= x1;
	x1 <= x;

end

					
endmodule
