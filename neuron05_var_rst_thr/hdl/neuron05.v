//##########################################################################
//## Neuron design Num.05 =>threshold and resting voltage variation 
//## Target device : Xilinx XCZU9EG-FFVB1156AAZ-1e
//## 
//## designed by Huiseong Noh
//## File created : 2021-03-24
//## Last edit : 2021-03-24
//############################################################################

//############################################################################
//## Info.
//## It is DUT(Design Under Test)(Verilog module).
//## Spike initiation model => threshold variation + resting volatage variation
//## The resting voltage doesn't get effect from input spikes
//## threshold and resting volatage both get effet from output spikes
//## But resting voltage variation can get effect for a long-term
//############################################################################

`timescale 1us / 100ns

module neuron05#(
	parameter   DATA_LENGTH				= 32,
	parameter	MAX_THRESHOLD_VOLTAGE	= 2**32*0.95,
	parameter	MIN_THRESHOLD_VOLTAGE	= 2**32*0.85,
	parameter	MAX_RESTING_VOLTAGE		= 2**32*0.15,
	parameter	MIN_RESTING_VOLTAGE		= 2**32*0.05,

	parameter	RESTING_CONTRIBUTION	= 2**32*0.1*0.4,
	parameter	THRESHOLD_CONTRIBUTION	= 2**32*0.1*0.3,

	parameter	RESTING_GROWTH			= 2**32*0.1*0.0002,	//0.005
	parameter	THRESHOLD_DECAY			= 2**32*0.1*0.001,

	parameter	TAU						= 1024,
	parameter	TAU_RST					= 1024)(
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
			r_int_vol <= r_rst_vol;
		end else begin
			if( r_int_vol < r_thr_vol ) begin
				if( r_int_vol <= r_rst_vol ) begin
					r_int_vol <= r_rst_vol + i_spike;
				end else begin
					r_int_vol <= r_int_vol - (r_int_vol-r_rst_vol)/TAU + i_spike;
				end
			end else begin
				r_int_vol <= r_rst_vol;
			end
		end
	end

	always@( posedge i_clk ) begin	// Resting and Threshold voltage contribution control
		if( i_rst == 1 ) begin
			r_rst_contrib <= 0;
			r_thr_contrib <= 0;
		end else begin
			if( o_spike != 0 ) begin
				r_rst_contrib <= RESTING_CONTRIBUTION;
				r_thr_contrib <= THRESHOLD_CONTRIBUTION;
			end else begin
				r_rst_contrib <= 0;
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
				//r_rst_vol <= MIN_RESTING_VOLTAGE + RESTING_GROWTH;
				r_rst_vol <= r_rst_vol + (MAX_RESTING_VOLTAGE - r_rst_vol)/1024;
			end else begin
				//r_rst_vol <= r_rst_vol - r_rst_contrib + RESTING_GROWTH;
				r_rst_vol <= r_rst_vol -r_rst_contrib + (MAX_RESTING_VOLTAGE - r_rst_vol)/TAU_RST;
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


