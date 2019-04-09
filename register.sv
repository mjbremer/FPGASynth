module register #(parameter WIDTH=32)
(input  logic Clk, Reset, Load,
              input  logic [WIDTH-1:0]  D,
              output logic [WIDTH-1:0]  Q);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a synchronous reset, which is recommended on the FPGA
			  Q <= {WIDTH{1'b0}};
		 else if (Load)
			  Q <= D;
    end
	
endmodule
