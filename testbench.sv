module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic CLK, RESET, key0, key1, key2, key3, Enable; 
logic [15:0] countermax;
logic out0, out1, out2, out3;
logic [2:0] state;

integer cont_wait;
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
Arpeggiator Arpeggiator0(.*);	


always_comb begin: INTERNAL_MONITORING
	out0 = Arpeggiator0.out0;
	out1 = Arpeggiator0.out1;
	out2 = Arpeggiator0.out2;
	out3 = Arpeggiator0.out3;
	state = Arpeggiator0.Curr_State;
	
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
RESET = 1;		// Toggle Rest

#2 RESET = 0;

#3 Enable = 1;
#3 countermax = 20;
#4 key0 = 1;
#4 key1 = 1;
#4 key2 = 1;
#4 key3 = 1;

end
endmodule
