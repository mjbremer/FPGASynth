module mux2_1
	#(parameter width = 16)
	 (input logic [width-1:0] A, B,
	  input logic sel,
	  output logic [width-1:0] Out);
	  
	always_comb
		begin	 
			case(sel)
				1'b0 : Out = A;
				1'b1 : Out = B;
				default : Out = {width{1'b0}};
			endcase
		end

endmodule

module mux4_1
	#(parameter width = 16)
	 (input logic [width-1:0] A, B, C, D,
	  input logic [1:0] sel,
	  output logic [width-1:0] Out);
	  
	always_comb
		begin
			case(sel)
				2'b00 : Out = A;
				2'b01 : Out = B;
				2'b10 : Out = C;
				2'b11 : Out = D;
				default : Out = {width{1'b0}};
			endcase
		end

endmodule

module mux8_1
	#(parameter width = 16)
	 (input logic [width-1:0] A, B, C, D, E, F, G, H,
	  input logic [2:0] sel,
	  output logic [width-1:0] Out);
	  
	always_comb
		begin
			case(sel)
				3'b000 : Out = A;
				3'b001 : Out = B;
				3'b010 : Out = C;
				3'b011 : Out = D;
				3'b100 : Out = E;
				3'b101 : Out = F;
				3'b110 : Out = G;
				3'b111 : Out = H;
				default : Out = {width{1'b0}};
			endcase
		end

endmodule

module Tri_Mux //16:1 Mux that replaces the four internal tri-state buffer
	#(parameter width = 16)
	 (input logic [width-1:0] ALU, MDR, PC, MARMUX,
	  input logic [3:0] sel,
	  output logic [width-1:0] Out
);

	always_comb
		begin
			case(sel)
				4'b1000 : Out = ALU;
				4'b0100 : Out = MDR;
				4'b0010 : Out = PC;
				4'b0001 : Out = MARMUX;
				default : Out = 16'dx;
			endcase
		end
endmodule


module Dmux1_8 //1:8 DMux with a variable bit width, default is 16
	#(parameter width = 16)
	 (input logic [width-1:0] In,
	  input logic [2:0] sel,
	  output logic [width-1:0] A, B, C, D, E, F, G, H);
	
	always_comb
		begin
			case(sel)
				3'b000 : begin
							A = In;
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b001 : begin
							A = {width{1'b0}};
							B = In;
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b010 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = In;
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b011 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = In;
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b100 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = In;
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b101 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = In;
							G = {width{1'b0}};
							H = {width{1'b0}};
							end
				3'b110 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = In;
							H = {width{1'b0}};
							end
				3'b111 : begin
							A = {width{1'b0}};
							B = {width{1'b0}};
							C = {width{1'b0}};
							D = {width{1'b0}};
							E = {width{1'b0}};
							F = {width{1'b0}};
							G = {width{1'b0}};
							H = In;
							end
			endcase
		end

endmodule

	