module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk, Reset;

// To store expected results
//logic [15:0] ans_1a, ans_2b;
				
// A counter to count the instances where simulation results
// do no match with expected results
//integer ErrorCnt = 0;

integer cont_wait;
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
lab6_toplevel lab6_toplevel0(.*);	


always_comb begin: INTERNAL_MONITORING
	MDR = lab6_toplevel0.my_slc.MDR;
	PC = lab6_toplevel0.my_slc.PC;
	IR = lab6_toplevel0.my_slc.IR;
	R0 = lab6_toplevel0.my_slc.d0.reg_file_inst.R[0];
	R1 = lab6_toplevel0.my_slc.d0.reg_file_inst.R[1];
	R2 = lab6_toplevel0.my_slc.d0.reg_file_inst.R[2];
	R7 = lab6_toplevel0.my_slc.d0.reg_file_inst.R[7];
	Bus = lab6_toplevel0.my_slc.d0.Bus;
	state = lab6_toplevel0.my_slc.state_controller.State;
	BEN = lab6_toplevel0.my_slc.state_controller.BEN;
end
	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
#1 cont_wait = cont_wait + 1;

if (cont_wait == 3)
	begin
		Continue = ~Continue;
		cont_wait = 0;
	end
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
	 cont_wait = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 0;		// Toggle Rest
Continue = 0;
Run = 1;
S = 16'hb;

#2 Reset = 1;

#3 Run = 0;

#4 Run = 1;
	

//#2 S = 8'h74;	// Toggle LoadB
//
//#2 Run = 0;	// Toggle Execute
//   
//#22 Run = 1;
//    ans_1a = (8'h8c * 8'h74); // Expected result of 1st cycle
//    // Aval is expected to be 8’h33 XOR 8’h55
//    // Bval is expected to be the original 8’h55
//    if ({Aval, Bval} != ans_1a)
//	 ErrorCnt++;
//
//#2 Execute = 0;	// Toggle Execute
//#2 Execute = 1;
//
//#22 Execute = 0;
//    // Aval is expected to stay the same
//    // Bval is expected to be the answer of 1st cycle XNOR 8’h55
//    if (Aval != ans_1a)	
//	 ErrorCnt++;
//    ans_2b = ~(ans_1a ^ 8'h55); // Expected result of 2nd  cycle
//    if (Bval != ans_2b)
//	 ErrorCnt++;
//    R = 2'b11;
//#2 Execute = 1;
//
//// Aval and Bval are expected to swap
//#22 if (Aval != ans_2b)
//	 ErrorCnt++;
//    if (Bval != ans_1a)
//	 ErrorCnt++;

//
//if (ErrorCnt == 0)
//	$display("Success!");  // Command line output in ModelSim
//else
//	$display("%d error(s) detected. Try again!", ErrorCnt);
end
endmodule
