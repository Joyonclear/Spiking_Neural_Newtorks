//############################################################################
//## Neuron design Num.02 => LIF model
//## Target device : Xilinx XCZU9EG-FFVB1156AAZ-1e
//## 
//## designed by Huiseong Noh
//## File created : 2021-03-13
//## Last edit : 2021-03-15
//############################################################################

//############################################################################
//## Info.
//## CUB + EXI, None of refractory, threshold variation
//############################################################################

`timescale 1ns / 1ps
`include "parameter_neuron.vh"

module neuron02_LIF(
    input							i_clk,
    input							i_rst,
    input		[`DATA_LENGTH-1:0]	i_spike,
    output reg						o_spike_lid,
    output reg						o_spike_exd
    );
    
    reg			[`DATA_LENGTH-1:0]	r_internal_state_lid;
	reg			[`DATA_LENGTH-1:0]	r_internal_state_exd;
	reg			[`DATA_LENGTH-1:0]	r_resting_voltage = `DATA_LENGTH'd700000;
    reg			[`DATA_LENGTH-1:0]	r_threshold	      = `DATA_LENGTH'd2147483647; //max of singed integer => half of data_length
	reg			[`DATA_LENGTH-1:0]	r_decay_ratio     = `DATA_LENGTH'd40000;
	reg			[`DATA_LENGTH-1:0]	r_tau_exd		  = `DATA_LENGTH'd5000;
	
    always@( posedge i_clk ) begin
		if( i_rst == 1 ) begin
			r_internal_state_lid <= 0;
			r_internal_state_exd <= 0;
			o_spike_lid <= 0;
			o_spike_exd <= 0;
		end else begin
			if( r_internal_state_lid < r_threshold ) begin
				o_spike_lid <= 0;
				if( r_internal_state_lid < r_resting_voltage ) begin
					r_internal_state_lid <= r_resting_voltage + i_spike;
				end else begin
					r_internal_state_lid <= r_internal_state_lid - r_decay_ratio + i_spike;
				end
			end else begin
				o_spike_lid <= 1;
				r_internal_state_lid <= r_resting_voltage;
			end

			if( r_internal_state_exd < r_threshold ) begin
				o_spike_exd <= 0;
				if( r_internal_state_exd < r_resting_voltage ) begin
					r_internal_state_exd <= r_resting_voltage + i_spike;
				end else begin
					r_internal_state_exd <= r_internal_state_exd - r_internal_state_exd/r_tau_exd + i_spike;
				end
			end else begin
				o_spike_exd <= 1;
				r_internal_state_exd <= r_resting_voltage;
			end
		end
	end
endmodule
