module ADSR (
	input	 logic CLK,
	input  logic RESET,
	input  logic key_in,
	input  logic [15:0] A, D, S, R,
	output logic [15:0] out
);

logic [15:0] level, level_next;
assign out = level;


enum logic [2:0] {ResetState, Attack, Decay, Sustain, Release, Done}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			Curr_State <= ResetState;
		else 
			Curr_State <= Next_state;
			
		level <= level_next;
		end
		

	
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = Curr_State;
		level_next = level;
	
		// Assign next state
		unique case (Curr_State)
			ResetState : 
			
			begin
				if (key_in) 
					Next_state = Attack;
			end
			
			Attack : 
			begin
				if (!key_in)
					Next_state = Release;
				else if ((level_next + A) > 16'h7FFF)
					begin
						level_next = 16'h7FFF;
						Next_state = Decay;
					end
				else if (level_next < 16'h7FFF)
					level_next = level + A;
				else
					Next_state = Decay;
					
			end
			
			Decay : 
			begin
			
				if (!key_in)
					Next_state = Release;
				else if (($signed(level_next - D)) < $signed(S))
					begin
						level_next = S;
						Next_state = Sustain;
					end
				else if (level_next > S)
					level_next = level - D;
				else
					Next_state = Sustain;
			end
			
			Sustain : 
			begin
				if (!key_in)
					Next_state = Release;
			end
			
			Release : 
			begin
				if (key_in)
				begin
					level_next = 0;
					Next_state = Attack;
				end
				else if ($signed(level_next) < $signed(0))
					begin
						level_next = 0;
						Next_state = Done;
					end
				else if (level_next > 0)
					level_next = level - R;
				else
					Next_state = Done;
			end
			
			Done : 
			begin
				if (key_in)
					Next_state = Attack;
			end		

			default : ;

		endcase


	end 

endmodule
