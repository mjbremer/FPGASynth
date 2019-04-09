/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module ADSR (
	input	 logic CLK,
	input  logic RESET,
	input  logic key_in,
	input  logic [15:0] A, D, S, R,
	output logic [15:0] out
);

logic [15:0] state;
assign out = state;


enum logic [2:0] {ResetState, Attack, Decay, Sustain, Release, Done}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			Curr_State <= ResetState;
		else 
			Curr_State <= Next_state;
		end
	
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = Curr_State;
	
		// Assign next state
		unique case (Curr_State)
			ResetState : 
			
			begin
				state = 0;
				if (key_in) 
					Next_state = Attack;
			end
			
			Attack : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if ((state + A) > 16'h7FFF)
					begin
						state = 16'h7FFF;
						Next_state = Decay;
					end
				else if (state < 16'h7FFF)
					state = state + A;
				else if (~key_in)
					Next_state = Release;
				else
					Next_state = Decay;
					
			end
			
			Decay : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if ((state - D) < S)
					begin
						state = S;
						Next_state = Sustain;
					end
				else if (state > S)
					state = state - D;
				else if (~key_in)
					Next_state = Release;
				else
					Next_state = Sustain;
			end
			
			Sustain : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if(key_in);
				else
					Next_state = Release;
			end
			
			Release : 
			begin
				if (RESET)
					Next_state = ResetState;
				if ($signed(state) < $signed(0))
					begin
						state = 0;
						Next_state = Done;
					end
				if (state > 0)
					state = state - R;
				else
					Next_state = Done;
			end
			
			Done : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if (key_in)
					Next_state = Attack;
				else
					Next_state = Done;
			end		

			default : ;

		endcase


	end 

endmodule
