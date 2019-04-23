module glide (input key_on, CLK, RESET, Enable,
				  input [15:0] state, in, glider,
				  output [15:0] out
);

logic [15:0] freq, freq_next;
assign out = freq;

enum logic [1:0] {ResetState, Key_false, Key_true}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			Curr_State <= ResetState;
		else 
			begin
				Curr_State <= Next_state;
				freq <= freq_next;
			end
	end
		

	
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = Curr_State;
		freq_next = freq;
	
		// Assign next state
		unique case (Curr_State)
			ResetState :
			begin
				if (Enable) 
					Next_state = Key_false;
				else
					freq_next = in;
			end
			
			Key_false : 
			begin
				if (!Enable)
					Next_state = ResetState;
				else if (RESET)
					Next_state = ResetState;
				else if (!key_on)
					begin
						freq_next = state;
						Next_state = Key_false;
					end
				else
					Next_state = Key_true;
					
			end
			
			Key_true : 
			begin
				if (!Enable)
					Next_state = ResetState;
				else if (RESET)
					Next_state = ResetState;
				else if (!key_on)
					Next_state = Key_false;
				else
					begin
						if (state > in)
							begin
								if((freq_next - glider) < in)
									freq_next = in;
								else if (freq_next > in)
									freq_next = freq_next - glider;
							end
						else if (state < in)
							begin
								if((freq_next + glider) > in)
									freq_next = in;
								else if (freq_next < in)
									freq_next = freq_next - glider;
							end
						else if (state == in)
							freq_next = state;
					end
					
			end

			default : ;

		endcase


	end 


endmodule 