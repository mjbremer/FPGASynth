module filtertestbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk, Reset, Enable;
logic signed [15:0] x, a0, a1, a2, b0, b1, b2;
logic signed [15:0] y;
filter top(.*);	


reg signed [15:0] x1,x2,y2,y1,y0;


logic signed [31:0] b0x0, b1x1, b2x2,a1y1, a2y2, a0y0;

always_comb begin: INTERNAL_MONITORING
x1 = top.x1;
x2 = top.x2;
y2 = top.y2;
y1 = top.y1;
y0 = top.y0;
b0x0 = top.b0x0;
b1x1 = top.b1x1;
b2x2 = top.b2x2;
a0y0 = top.a0y0;
a1y1 = top.a1y1;
a2y2 = top.a2y2;
end
	
	
always_comb begin

a0 = 16'h1559;
a1 = 16'hfb73;
a2 = 16'heff6;
b0 = 16'h1123;
b1 = 16'h2246;
b2 = 16'h1123;
end

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 1;		// Toggle Reset
x = 16'b0;
#4 Enable = 1'b1;

#2 Reset = 0;


#1 x = 16'hECEB;
#1 x = 16'hDEAD;
	
end
endmodule
