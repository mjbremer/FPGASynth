module glide (input CLK, RESET,
				  input [23:0] in, rate,
				  output [23:0] out
);

logic [23:0] freq, freq_next;
assign out = freq;

enum logic [1:0] {ResetState, Key_false, Key_true}   Curr_State, Next_state;   // Internal state logic

	always_ff @ (posedge CLK)
	begin
	freq = freq_next;
	
		if (RESET)
		begin
			freq = in;
			freq_next = in;
		end
		else 
		begin
				if (freq < in)
				begin
				
					if (freq + rate < in)
					begin
						freq_next = freq+rate;
					end
					else
					begin
						freq_next = in;
					end
				end
				
				else if (freq > in)
				begin
					if (freq - rate > in)
					begin
						freq_next = freq-rate;
					end
					else
					begin
						freq_next = in;
					end
				end
		end
	end
endmodule 