module arptestbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic key0, key1, key2, key3, key4, key5, key6, key7, CLK, RESET, Enable, PingPongEn;
logic [15:0] countermax; //this tells us how long to stay on each note
logic out0, out1, out2, out3, out4, out5, out6, out7;

Arpeggiator top(.*);	


logic on0, on1, on2, on3, on4, on5, on6, on7;
integer counter, counter_next;
logic [3:0] Curr_State, Next_State;   // Internal state logic

always_comb begin: INTERNAL_MONITORING
on0 = top.on0;
on1 = top.on1;
on2 = top.on2;
on3 = top.on3;
on4 = top.on4;
on5 = top.on5;
on6 = top.on6;
on7 = top.on7;
counter = top.counter;
Curr_State = top.Curr_State;
Next_State = top.Next_State;
end
	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end

initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
RESET = 1;		// Toggle Reset
countermax = 2;

#2 RESET = 0;

Enable = 1'b0;
PingPongEn = 1'b0;

key0 = 1'b1;
key1 = 1'b1;
key2 = 1'b1;
key3 = 1'b1;
key4 = 1'b1;
key5 = 1'b1;
key6 = 1'b1;
key7 = 1'b1;


#4 Enable = 1'b1;

	
end
endmodule
