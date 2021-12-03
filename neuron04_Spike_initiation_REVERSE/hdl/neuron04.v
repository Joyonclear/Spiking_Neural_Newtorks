//##########################################################################
//## Neuron design Num.04 => Spike initiation model Reverse
//## Target device : Xilinx XCZU9EG-FFVB1156AAZ-1e
//## 
//## designed by Huiseong Noh
//## File created : 2021-03-22
//## Last edit : 2021-03-24
//############################################################################

//############################################################################
//## Info.
//## It is DUT(Design Under Test)(Verilog module).
//## Spike initiation model => threshold variation + resting volatage variation
//## REVERSE Model => Each neuron try to be equivalent. 
//############################################################################

`timescale 1us / 100ns
//`include "parameter_neuron.vh"

module neuron04#(
	parameter   DATA_LENGTH				= 32,
	parameter	MAX_THRESHOLD_VOLTAGE	= 4080218931,	//2**32*0.95
	parameter	MIN_THRESHOLD_VOLTAGE	= 3650722201,	//2**32*0.85
	parameter	MAX_RESTING_VOLTAGE		= 644245094,	//2**32*0.15
	parameter	MIN_RESTING_VOLTAGE		= 214748364,	//2**32*0.05

	parameter	RESTING_CONTRIBUTION	= 2**32*0.1*0.5,
	parameter	THRESHOLD_CONTRIBUTION	= 2**32*0.1*0.5,

	parameter	RESTING_GROWTH			= 2**32*0.1*0.005,	//0.005
	parameter	THRESHOLD_DECAY			= 2**32*0.1*0.001,

	parameter	TAU						= 1024)(
	// Neuron's real I/O ports
    input							i_clk,
    input							i_rst,
    input		[DATA_LENGTH-1:0]	i_spike,
    output reg						o_spike,
	//Virtual I/O ports for monitoring the neuron's operation
	output reg	[DATA_LENGTH-1:0]	o_internal_state,
	output reg	[DATA_LENGTH-1:0]	o_rst_vol,
	output reg	[DATA_LENGTH-1:0]	o_thr_vol
    );
	
	reg			[DATA_LENGTH-1:0]	r_int_vol;	//register insternal voltage
	reg			[DATA_LENGTH-1:0]	r_rst_vol;	//register resting voltage
    reg			[DATA_LENGTH-1:0]	r_thr_vol;	//register threshold voltage
	
    reg			[DATA_LENGTH-1:0]	r_rst_contrib;
    reg			[DATA_LENGTH-1:0]	r_thr_contrib;

	assign o_internal_state = r_int_vol; 
	assign o_rst_vol = r_rst_vol; 
	assign o_thr_vol = r_thr_vol; 
	
	always@( posedge i_clk ) begin	// Output spike control
		if( i_rst == 1 ) begin
			o_spike <= 0;
		end else begin
			if( r_int_vol < r_thr_vol ) begin
				o_spike <= 0;
			end else begin
				o_spike <= 1;
			end
		end
	end

    always@( posedge i_clk ) begin	// Neuron's internal state control
		if( i_rst == 1 ) begin
			//r_int_vol <= r_rst_vol;
			r_int_vol <= 0;
		end else begin
			if( r_int_vol < r_thr_vol ) begin
				if( r_int_vol <= r_rst_vol ) begin
					r_int_vol <= r_int_vol + i_spike;
				end else begin
					r_int_vol <= r_int_vol - (r_int_vol-r_rst_vol)/TAU + i_spike;
				end
			end else begin
				r_int_vol <= r_rst_vol;
			end
		end
	end

	always@( posedge i_clk ) begin	// Resting voltage contribution control
		if( i_rst == 1 ) begin
			r_rst_contrib <= 0;
		end else begin
			if( i_spike != 0 ) begin
				r_rst_contrib <= RESTING_CONTRIBUTION;
			end else begin
				r_rst_contrib <= 0;
			end
		end
	end

	always@( posedge i_clk ) begin	// Threshold voltage contribution control
		if( i_rst == 1 ) begin
			r_thr_contrib <= 0;
		end else begin
			if( o_spike != 0 ) begin
				r_thr_contrib <= THRESHOLD_CONTRIBUTION;
			end else begin
				r_thr_contrib <= 0;
			end
		end
	end
					
	always@( posedge i_clk ) begin	// Resting voltage(V0) control
		if( i_rst == 1 ) begin
			r_rst_vol <= MAX_RESTING_VOLTAGE;
		end else begin
			if( r_rst_vol >= MAX_RESTING_VOLTAGE ) begin
				r_rst_vol <= MAX_RESTING_VOLTAGE - r_rst_contrib; 
			end else if( r_rst_vol <= MIN_RESTING_VOLTAGE ) begin
				r_rst_vol <= MIN_RESTING_VOLTAGE + RESTING_GROWTH;
			end else begin
				r_rst_vol <= r_rst_vol - r_rst_contrib + RESTING_GROWTH;
			end
		end
	end
	
	always@( posedge i_clk ) begin	// Threshold voltage(theta) control
		if( i_rst == 1 ) begin
			r_thr_vol <= MIN_THRESHOLD_VOLTAGE;
		end else begin
			if( r_thr_vol >= MAX_THRESHOLD_VOLTAGE ) begin
				r_thr_vol <= MAX_THRESHOLD_VOLTAGE - THRESHOLD_DECAY;
			end else if( r_thr_vol <= MIN_THRESHOLD_VOLTAGE ) begin
				r_thr_vol <= MIN_THRESHOLD_VOLTAGE + r_thr_contrib;
			end else begin
				r_thr_vol <= r_thr_vol + r_thr_contrib - THRESHOLD_DECAY;
			end
		end
	end
endmodule


