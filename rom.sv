module rom
#(
parameter INPUT_MEM_FILE ="",
parameter ADDRWIDTH = 12, // For 4096 addresses
parameter WIDTH = 16
)
(
        input Clk, Reset, CS,
        input [ADDRWIDTH-1:0] addr, // Address lines for saving data to memory
        output logic [WIDTH-1:0] data // Data out
);

reg [WIDTH-1:0] memory [0:(2**ADDRWIDTH)-1];

integer i;
initial begin
	  $readmemh(INPUT_MEM_FILE, memory);
//     for (i=0; i < 4096; i=i+1)
//        $display("%d:%h",i,memory[i]);
end


//assign data = memory[addr];
always @(posedge Clk) begin
	//memory[12'h025] <= 16'hDEAD;
    // Place data from RAM
	 if (Reset || !CS)
	 begin
		data <= {WIDTH{1'bx}};
	 end
	 else begin
		data <= memory[addr];
	 end
end        
endmodule
