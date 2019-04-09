module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.

logic AUD_XCK,  AUD_DACDAT, I2C_SDAT, I2C_SCLK;
logic AUD_BCLK, AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, CLOCK_50;
logic [3:0] Key;
logic SR;
logic [23:0] phase;
logic [15:0] out;
logic [11:0] rom_in;
logic [15:0] rom_out;
logic [3:0] KEY;
logic [17:0] SW;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
synth synth0(.*);	


always_comb begin: INTERNAL_MONITORING
	SR = synth0.Clk;
	phase = synth0.osc0.Phase_out;
	out = synth0.osc0.out;
	rom_in = synth0.osc0.sine.addr;
	rom_out = synth0.osc0.sine.data;
end
	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 CLOCK_50 = ~CLOCK_50;
end

initial begin: CLOCK_INITIALIZATION
    CLOCK_50 = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
KEY[3] = 0;		// Toggle Reset

#1300 KEY[3] = 1;

end
endmodule
