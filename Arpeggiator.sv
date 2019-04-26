module Arpeggiator (input logic key0, key1, key2, key3, CLK, RESET, Enable, 
						  input logic [15:0] countermax, //this tells us how long to stay on each note
						  output logic out0, out1, out2, out3
);

logic on0, on1, on2, on3;
logic [15:0] counter, counter_next;

enum logic [2:0] {ResetState, Bypass, Key0, Key1, Key2, Key3}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			Curr_State <= ResetState;
		else 
			begin
				Curr_State <= Next_state;
				counter <= counter_next;
				out0 <= on0;
				out1 <= on1;
				out2 <= on2;
				out3 <= on3;
			end
	end

	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = Curr_State;
		counter_next = counter;
		on0 = 1'b0;
		on1 = 1'b0;
		on2 = 1'b0;
		on3 = 1'b0;
	
		// Assign next state
		unique case (Curr_State)
			ResetState :
			begin
				if (!RESET) 
					Next_state = Bypass;
				else ;
			end
			
			Bypass :	//if not enabled let all key_ons be passed through
			begin
				if (!Enable)
					begin
						Next_state = Bypass;
						on0 = key0;
						on1 = key1;
						on2 = key2;
						on3 = key3;
					end
				else if (RESET)
					Next_state = ResetState;
				else
					Next_state = Key0;		
			end
			
			Key0 :	//stay on the first pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_state = Bypass;
				else if (RESET)
					Next_state = ResetState;
				else if ((counter_next > countermax) || !key0)
					begin
						counter_next = 16'b0;
						Next_state = Key1;
					end
				else
					begin
						counter_next = counter_next + 1'b1;
						on0 = key0;
					end		
			end
			
			Key1 :	//stay on the second pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_state = Bypass;
				else if (RESET)
					Next_state = ResetState;
				else if ((counter_next > countermax) || !key1)
					begin
						counter_next = 0;
						Next_state = Key2;
					end
				else
					begin
						counter_next = counter_next + 1;
						on1 = key1;
					end		
			end
			
			Key2 :	//stay on the third pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_state = Bypass;
				else if (RESET)
					Next_state = ResetState;
				else if ((counter_next > countermax) || !key2)
					begin
						counter_next = 0;
						Next_state = Key3;
					end
				else
					begin
						counter_next = counter_next + 1;
						on2 = key2;
					end		
			end
			
			Key3 : //stay on the fourth pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_state = Bypass;
				else if (RESET)
					Next_state = ResetState;
				else if ((counter_next > countermax) || !key3)
					begin
						counter_next = 0;
						Next_state = Key0;
					end
				else
					begin
						counter_next = counter_next + 1;
						on3 = key3;
					end		
			end

			default : ;

		endcase


	end 


endmodule 