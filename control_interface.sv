/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module control_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	output logic [15:0]ATTACK,RLEASE,SUSTAIN,DECAY,
	output logic [1:0] SHAPE1,SHAPE0,
	output logic [6:0] FREQ0, FREQ1, FREQ2, FREQ3,
	output logic [15:0] AMP1_0, AMP0_0, AMP1_1, AMP0_1, AMP1_2, AMP0_2, AMP1_3, AMP0_3,
	output logic KEY3, KEY2, KEY1, KEY0,
	
	input logic [5:0] AVL_ADDR,
	input logic [3:0] AVL_BYTE_EN,
	input logic AVL_READ, AVL_WRITE, AVL_CS,
	input logic [31:0] AVL_WRITEDATA,
	output logic [31:0] AVL_READDATA
);

   logic [31:0] reg_file [0:63];
	logic [31:0] reg_file_next [0:63];
	
	
	assign ATTACK = reg_file[7][15:0];
	
	
	always_ff @ (posedge CLK)
	begin
		if (RESET)
		begin
			for (integer i=0; i<64; i=i+1) begin
				reg_file[i] <= 0;
			end
		end
		else if (AVL_WRITE & AVL_CS)
			begin
				reg_file[AVL_ADDR] = AVL_WRITEDATA;
			end
		else if (AVL_READ & AVL_CS)
			begin
				AVL_READDATA = reg_file[AVL_ADDR];
			end
		else
		begin
			AVL_READDATA = 32'bx;
		end
		
		
	end
	
endmodule
