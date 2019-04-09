//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module Initializer (
				input logic INIT_FINISH, Clk, Reset, 
				output logic INIT
);

	enum logic [1:0] {init, data}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= init;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		// Assign next state
		unique case (State)
			init : 
				if (INIT_FINISH) 
					Next_state = data;                      
			default : ;
		endcase
		
		// Assign control signals based on current state
		case (State)
			init : 
				begin 
					INIT = 1'b1;
				end
			data : 
				begin
					INIT = 1'b0;
				end
			default : ;
		endcase
	end 
endmodule
