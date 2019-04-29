module Arpeggiator (input logic key0, key1, key2, key3, key4, key5, key6, key7, CLK, RESET, Enable, PingPongEn,
						  input logic [15:0] countermax, //this tells us how long to stay on each note
						  output logic out0, out1, out2, out3, out4, out5, out6, out7
);

logic on0, on1, on2, on3, on4, on5, on6, on7, direction, direction_next;
logic [15:0] counter, counter_next;
assign out0 = on0;
assign out1 = on1;
assign out2 = on2;
assign out3 = on3;
assign out4 = on4;
assign out5 = on5;
assign out6 = on6;
assign out7 = on7;

enum logic [3:0] {ResetState, Bypass, Key0, Key1, Key2, Key3, Key4, Key5, Key6, Key7}   Curr_State, Next_State;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
		if (RESET) 
		begin
			Curr_State <= ResetState;
			counter <= 0;
			direction <= 0;
		end
		else if (!Enable)
		begin
			Curr_State <= Bypass;
			counter <= 0;
			direction <= 1'b0;
		end
		else
		begin
		Curr_State <= Next_State;		
		counter <= counter_next;
		direction <= direction_next;
		end


	end

	always_comb
	begin 
		// Default next state is staying at current state
		Next_State = Curr_State;
		direction_next = direction;
		counter_next = counter;
		on0 = 1'b0;
		on1 = 1'b0;
		on2 = 1'b0;
		on3 = 1'b0;
		on4 = 1'b0;
		on5 = 1'b0;
		on6 = 1'b0;
		on7 = 1'b0;
	
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
				on4 = key4;
				on5 = key5;
				on6 = key6;
				on7 = key7;
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
						direction_next = 1'b0;
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
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0)
										Next_State = Key0;
								else
									begin
										Next_State = Key2;
										direction_next = 1'b0;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key2 | key3 | key4 | key5 | key6 | key7)
									Next_State = Key2;
								else
									begin
										Next_State = Key0;
										direction_next = 1'b1;
									end
							end
						else
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
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0 | key1)
									Next_State = Key1;
								else
									begin
										direction_next = 1'b0;
										Next_State = Key3;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key3 | key4 | key5 | key6 | key7)
									Next_State = Key3;
								else
									begin
										Next_State = Key1;
										direction_next = 1'b1;
									end
							end
						else
							Next_State = Key3;
					end
				else
					begin
						counter_next = counter_next + 1;
						on2 = key2;
					end		
			end
			
			Key3 :	//stay on the fourth pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key3)
					begin
						counter_next = 0;
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0 | key1 | key2)
									Next_State = Key2;
								else
									begin
										direction_next = 1'b0;
										Next_State = Key4;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key4 | key5 | key6 | key7)
									Next_State = Key4;
								else
									begin
										Next_State = Key2;
										direction_next = 1'b1;
									end
							end
						else
							Next_State = Key4;
					end
				else
					begin
						counter_next = counter_next + 1;
						on3 = key3;
					end		
			end
			
		Key4 :	//stay on the fifth pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key4)
					begin
						counter_next = 0;
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0 | key1 | key2 | key3)
									Next_State = Key3;
								else
									begin
										direction_next = 1'b0;
										Next_State = Key5;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key5 | key6 | key7)
									Next_State = Key5;
								else
									begin
										Next_State = Key3;
										direction_next = 1'b1;
									end
							end
						else
							Next_State = Key5;
					end
				else
					begin
						counter_next = counter_next + 1;
						on4 = key4;
					end		
			end
			
		Key5 :	//stay on the sixth pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key5)
					begin
						counter_next = 0;
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0 | key1 | key2 | key3 | key4)
									Next_State = Key4;
								else
									begin
										direction_next = 1'b0;
										Next_State = Key6;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key6 | key7)
									Next_State = Key6;
								else
									begin
										Next_State = Key4;
										direction_next = 1'b1;
									end
							end
						else
							Next_State = Key6;
					end
				else
					begin
						counter_next = counter_next + 1;
						on5 = key5;
					end		
			end
			
		Key6 :	//stay on the seventh pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key6)
					begin
						counter_next = 0;
						if (PingPongEn & (direction == 1'b1))
							begin
								if (key0 | key1 | key2 | key3 | key4 | key5)
									Next_State = Key5;
								else
									begin
										direction_next = 1'b0;
										Next_State = Key7;
									end
							end
						else if (PingPongEn & (direction == 1'b0))
							begin
								if (key7)
									Next_State = Key7;
								else
									begin
										Next_State = Key5;
										direction_next = 1'b1;
									end
							end
						else
							Next_State = Key7;
					end
				else
					begin
						counter_next = counter_next + 1;
						on6 = key6;
					end		
			end
			
		Key7 :	//stay on the eight pressed note for a certain amount of time
			begin
				if (!Enable)
					Next_State = Bypass;
				else if ((counter_next > countermax) | !key7)
					begin
						counter_next = 0;
						if (PingPongEn)
							begin
								Next_State = Key6;
								direction_next = 1'b1;
							end
						else
							Next_State = Key0;
					end
				else
					begin
						counter_next = counter_next + 1'b1;
						on7 = key7;
					end		
			end

			default : ;

		endcase


	end 


endmodule 