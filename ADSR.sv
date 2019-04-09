module ADSR (
	input	 logic CLK,
	input  logic RESET,
	input  logic key_in,
	input  logic [15:0] A, D, S, R,
	output logic [15:0] out
);

logic [15:0] state, state_next;
assign out = state;


enum logic [2:0] {ResetState, Attack, Decay, Sustain, Release, Done}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			Curr_State <= ResetState;
		else 
			Curr_State <= Next_state;
			
				state <= state_next;
		end
		

	
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = Curr_State;
		state_next = state;
	
		// Assign next state
		unique case (Curr_State)
			ResetState : 
			
			begin
				if (key_in) 
					Next_state = Attack;
			end
			
			Attack : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if ((state_next + A) > 16'h7FFF)
					begin
						state_next = 16'h7FFF;
						Next_state = Decay;
					end
				else if (state_next < 16'h7FFF)
					state_next = state_next + A;
				else if (~key_in)
					Next_state = Release;
				else
					Next_state = Decay;
					
			end
			
			Decay : 
			begin
				if (RESET)
					Next_state = ResetState;
				else if ((state_next - D) < S)
					begin
						state_next = S;
						Next_state = Sustain;
					end
				else if (state_next > S)
					state_next = state - D;
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
				if ($signed(state_next) < $signed(0))
					begin
						state_next = 0;
						Next_state = Done;
					end
				if (state_next > 0)
					state_next = state_next - R;
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
