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
	output logic ARP_EN, GLIDE_EN,
	output logic [15:0] ARP_TIME, PANNING,
	output logic [24:0] GLIDE_RATE,
	output logic PINGPONGEN, AUTO_PAN_EN,
	
	output logic [6:0] FREQ0, FREQ1, FREQ2, FREQ3,
	output logic [15:0] AMP1_0, AMP0_0, AMP1_1, AMP0_1, AMP1_2, AMP0_2, AMP1_3, AMP0_3,
	output logic KEY3, KEY2, KEY1, KEY0,
	output logic [6:0] FREQ4, FREQ5, FREQ6, FREQ7,
	output logic [15:0] AMP1_4, AMP0_4, AMP1_5, AMP0_5, AMP1_6, AMP0_6, AMP1_7, AMP0_7,
	output logic KEY4, KEY5, KEY6, KEY7,
	
	output logic FILTER_EN,
	output logic [15:0] FILTER_A0, FILTER_A1, FILTER_A2, FILTER_B0, FILTER_B1, FILTER_B2,
	
	
	input logic [5:0] AVL_ADDR,
	input logic [3:0] AVL_BYTE_EN,
	input logic AVL_READ, AVL_WRITE, AVL_CS,
	input logic [31:0] AVL_WRITEDATA,
	output logic [31:0] AVL_READDATA
);

   logic [31:0] reg_file [0:63];
	//logic [31:0] reg_file_next [0:63];
	
	
	assign SHAPE1 = reg_file[0][1:0];
	assign SHAPE0 = reg_file[1][1:0];
	assign ATTACK = reg_file[2][15:0];
	assign DECAY = reg_file[3][15:0];
	assign SUSTAIN = reg_file[4][15:0];
	assign RLEASE = reg_file[5][15:0];
	assign GLIDE_EN = reg_file[6][0];
	assign GLIDE_RATE = reg_file[7][24:0];
	assign ARP_EN = reg_file[8][0];
	assign ARP_TIME = reg_file[9][15:0];
	assign PINGPONGEN = reg_file[10][0];
	assign PANNING = reg_file[11][15:0];
	assign AUTO_PAN_EN = reg_file[12][0];
	
	assign FILTER_EN = reg_file[13][0];
	assign FILTER_A0 = reg_file[14][15:0];
	assign FILTER_A1 = reg_file[15][15:0];
	assign FILTER_A2 = reg_file[16][15:0];
	assign FILTER_B0 = reg_file[17][15:0];
	assign FILTER_B1 = reg_file[18][15:0];
	assign FILTER_B2 = reg_file[19][15:0];
	
	assign KEY0 = reg_file[32][0];
	assign KEY1 = reg_file[33][0];
	assign KEY2 = reg_file[34][0];
	assign KEY3 = reg_file[35][0];
	assign KEY4 = reg_file[36][0];
	assign KEY5 = reg_file[37][0];
	assign KEY6 = reg_file[38][0];
	assign KEY7 = reg_file[39][0];
	
	assign FREQ0 = reg_file[40][6:0];
	assign FREQ1 = reg_file[41][6:0];
	assign FREQ2 = reg_file[42][6:0];
	assign FREQ3 = reg_file[43][6:0];
	assign FREQ4 = reg_file[44][6:0];
	assign FREQ5 = reg_file[45][6:0];
	assign FREQ6 = reg_file[46][6:0];
	assign FREQ7 = reg_file[47][6:0];
	
	assign AMP1_0 = reg_file[48][15:0];
	assign AMP1_1 = reg_file[49][15:0];
	assign AMP1_2 = reg_file[50][15:0];
	assign AMP1_3 = reg_file[51][15:0];
	assign AMP1_4 = reg_file[52][15:0];
	assign AMP1_5 = reg_file[53][15:0];
	assign AMP1_6 = reg_file[54][15:0];
	assign AMP1_7 = reg_file[55][15:0];
	
	assign AMP0_0 = reg_file[56][15:0];
	assign AMP0_1 = reg_file[57][15:0];
	assign AMP0_2 = reg_file[58][15:0];
	assign AMP0_3 = reg_file[59][15:0];
	assign AMP0_4 = reg_file[60][15:0];
	assign AMP0_5 = reg_file[61][15:0];
	assign AMP0_6 = reg_file[62][15:0];
	assign AMP0_7 = reg_file[63][15:0];
	
	
	// Select Regs to output from regfile
always_comb
begin
	if (AVL_READ & AVL_CS)
		AVL_READDATA = reg_file[AVL_ADDR];
	else
		AVL_READDATA = 32'dx;
end

	
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
		
		
	end
	
endmodule
