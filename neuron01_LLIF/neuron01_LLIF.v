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
//## First test file for spiking neural network simulation
//############################################################################

`timescale 1ns / 1ps

module neuron01_LLIF
	#(
	//`include "parameter_neuron.v"
	parameter DATA_LENGTH = 8
	)
	(
    input                           i_clk,
    input							i_rst,
    input		[DATA_LENGTH-1:0]	i_spike,
    output reg						o_spike
    );
    
    reg			[DATA_LENGTH-1:0]	r_internal_state;
    reg			[DATA_LENGTH-1:0]	r_threshold = 200;
	reg			[2:0]				r_decay_ratio = 3;
	
    always@( posedge i_clk ) begin
		if( i_rst == 1 ) begin
			r_internal_state <= 0;
			o_spike <= 0;
		end else begin
			if( r_internal_state + i_spike < r_decay_ratio ) begin
				r_internal_state <= 0;
				o_spike <= 0;
			end else begin
				if( r_internal_state < r_threshold ) begin
					r_internal_state <= r_internal_state - r_decay_ratio + i_spike;
					o_spike <= 0;
				end else begin
					r_internal_state <= 0;
					o_spike <= 1;
				end
			end
		end
	end
endmodule
