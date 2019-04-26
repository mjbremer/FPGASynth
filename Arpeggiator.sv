module Arpeggiator (input logic key0, key1, key2, key3, CLK, RESET, Enable, 
						  input logic [15:0] countermax, //this tells us how long to stay on each note
						  output logic out0, out1, out2, out3
);

logic on0, on1, on2, on3;
logic [15:0] counter, counter_next;
assign out0 = on0;
assign out1 = on1;
assign out2 = on2;
assign out3 = on3;

enum logic [2:0] {ResetState, Bypass, Key0, Key1, Key2, Key3}   Curr_State, Next_State;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
		begin
			Curr_State <= ResetState;
			counter <= 0;
		end
		else if (!Enable)
		begin
			Curr_State <= Bypass;
			counter <= 0;
		end
		else
		begin
		Curr_State <= Next_State;		
		counter <= counter_next;
		end


	end

	always_comb
	begin 
		// Default next state is staying at current state
		Next_State = Curr_State;
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
				begin
					Next_State = Bypass;
					counter_next = 0;
				end
			end
			
			Bypass :	//if not enabled let all key_ons be passed through
			begin
				on0 = key0;
				on1 = key1;
				on2 = key2;
				on3 = key3;
				if (Enable)
				begin
					Next_State = Key0;
					counter_next = 0;
				end
			end
			
			Key0 :	//stay on the first pressed note for a certain amount of time
			begin
				if (!Enable)

					Next_State = Bypass;
				else if ((counter_next > countermax) | !key0)
					begin
						counter_next = 0;
						Next_State = Key1;

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

					Next_State = Bypass;
				else if ((counter_next > countermax) | !key1)
					begin
						counter_next = 0;
						Next_State = Key2;
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
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key2)
					begin
						counter_next = 0;
						Next_State = Key3;
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

					Next_State = Bypass;
				else if ((counter_next > countermax) | !key3)
					begin
						counter_next = 0;
						Next_State = Key0;
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