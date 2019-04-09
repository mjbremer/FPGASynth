module dual_port_rom (
input [11:0] addr_a, addr_b,
input clk,
output reg [15:0] q_a, q_b
);
reg [15:0] rom[4095:0];
initial // Read the memory contents in the file
//dual_port_rom_init.txt.
begin
$readmemh("C:\\Users\\Matt\\ece-385\\synth\\sine.mem", rom);
end
always @ (posedge clk)
begin
q_a <= rom[addr_a];
q_b <= rom[addr_b];
end
endmodule
