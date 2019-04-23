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

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
	
);

   logic [31:0] reg_file [0:15];
	logic [31:0] reg_file_next [0:15];
	
	
	assign EXPORT_DATA = reg_file[7];
	
	
	always_ff @ (posedge CLK)
	begin
		if (RESET)
		begin
		reg_file[0] = 32'b0;
		reg_file[1] = 32'b0;
		reg_file[2] = 32'b0;
		reg_file[3] = 32'b0;
		reg_file[4] = 32'b0;
		reg_file[5] = 32'b0;
		reg_file[6] = 32'b0;
		reg_file[7] = 32'b0;
		reg_file[8] = 32'b0;
		reg_file[9] = 32'b0;
		reg_file[10] = 32'b0;
		reg_file[11] = 32'b0;
		reg_file[12] = 32'b0;
		reg_file[13] = 32'b0;
		reg_file[14] = 32'b0;
		reg_file[15] = 32'b0;
		end
		else if (AVL_WRITE & AVL_CS)
			begin
				reg_file[AVL_ADDR] = AVL_WRITEDATA;
			end
		else
			begin 
			for (integer i=8; i<12; i=i+1) begin
				reg_file[i] <= reg_file_next[i];
			end
			reg_file[15] <= reg_file_next[15];
		end
	
	
	
		if (AVL_READ & AVL_CS)
		begin
			AVL_READDATA = reg_file[AVL_ADDR];
		end
		else
		begin
			AVL_READDATA = 32'bx;
		end
		
		
	end
	
	
	logic aes_start, aes_done;
	logic [127:0] aes_key, aes_msg_dec, aes_msg_enc;
	assign aes_start = reg_file[14][0];
	assign aes_done = reg_file[15][0];
	assign aes_key = {reg_file[0], reg_file[1], reg_file[2], reg_file[3]};
	assign aes_msg_enc = {reg_file[4], reg_file[5], reg_file[6], reg_file[6]};
	assign aes_msg_dec = {reg_file[7], reg_file[8], reg_file[9], reg_file[10]};
	AES AES0 (.CLK(CLK),
				 .RESET(RESET), 
				 .AES_START(aes_start), 
				 .AES_DONE(aes_done), 
				 .AES_KEY(aes_key), 
				 .AES_MSG_ENC(aes_msg_enc), 
				 .AES_MSG_DEC(aes_msg_dec));
	
endmodule
