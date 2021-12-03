//############################################################################
//## Neuron design Num.01 => LLIF model
//## Target device : Xilinx XCZU9EG-FFVB1156AAZ-1e
//## 
//## designed by Huiseong Noh
//## File created : 2021-03-12
//## Last edit : 2021-03-13
//############################################################################

//############################################################################
//## Info.
//## test bench for 01 LLIF model
//############################################################################

`timescale 1ns / 1ps

module tb_01;
		reg clk;
		reg[7:0] in;

always
	#5 clk = ~clk;

initial begin
	clk = 0;
	in	= 0;

# 50
	in = 60;
# 10
	in = 0;
# 50
	in = 50;
# 10
	in = 0;
# 50
	in = 80;
# 10
	in = 0;
# 50
	in = 60;
# 10
	in = 0;
# 50
	in = 70;
# 10
	in = 0;
#50
$finish;
end


neuron01_LLIF u0(
		.i_clk(clk),
		.i_rst(1'b0),
		.i_spike(in),
        .o_spike()
	 );
    
endmodule
