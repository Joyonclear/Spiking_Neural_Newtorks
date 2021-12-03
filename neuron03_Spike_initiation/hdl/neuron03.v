//############################################################################
//## Neuron design Num.03 => Spike initiation model
//## Target device : Xilinx XCZU9EG-FFVB1156AAZ-1e
//## 
//## designed by Huiseong Noh
//## File created : 2021-03-17
//## Last edit : 2021-03-20
//############################################################################

//############################################################################
//## Info.
//## It is DUT(Design Under Test)(Verilog module).
//## Spike initiation model => threshold variation + resting volatage variation
//############################################################################

`timescale 1us / 100ns
`include "parameter_neuron.vh"

module neuron03(
    input							i_clk,
    input							i_rst,
    input		[`DATA_LENGTH-1:0]	i_spike,
    output reg						o_spike,
	output reg	[`DATA_LENGTH-1:0]	o_internal_state
    );
	
	reg			[`DATA_LENGTH-1:0]	r_int_vol;	//register insternal voltage
	reg			[`DATA_LENGTH-1:0]	r_rst_vol;	//register resting voltage
    reg			[`DATA_LENGTH-1:0]	r_thr_vol;	//register threshold voltage
	
    reg			[`DATA_LENGTH-1:0]	r_max_thr_vol = `DATA_LENGTH'd`MAX_THRESHOLD_VOLTAGE; 	
    reg			[`DATA_LENGTH-1:0]	r_min_thr_vol = `DATA_LENGTH'd`MIN_THRESHOLD_VOLTAGE; 	
    reg			[`DATA_LENGTH-1:0]	r_max_rst_vol = `DATA_LENGTH'd`MAX_RESTING_VOLTAGE; 	
    reg			[`DATA_LENGTH-1:0]	r_min_rst_vol = `DATA_LENGTH'd`MIN_RESTING_VOLTAGE; 	

    reg			[`DATA_LENGTH-1:0]	r_rst_contib  = `DATA_LENGTH'd`RESTING_CONTRIBUTION; 	
    reg			[`DATA_LENGTH-1:0]	r_thr_contib  = `DATA_LENGTH'd`THRESHOLD_CONTRIBUTION;

    reg			[`DATA_LENGTH-1:0]	r_rst_decay	  = `DATA_LENGTH'd`RESTING_DECAY; 	
    reg			[`DATA_LENGTH-1:0]	r_thr_growth  = `DATA_LENGTH'd`THRESHOLD_GROWTH; 	
	
	//assign o_internal_state = r_int_vol;
	assign o_internal_state = r_int_vol; 
	
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
					r_int_vol <= r_int_vol - r_int_vol/`TAU + i_spike;
				end
			end else begin
				r_int_vol <= r_rst_vol;
			end
		end
	end

	always@( posedge i_clk ) begin	// Resting voltage contribution control
		if( i_rst == 1 ) begin
			r_rst_contib <= 0;
		end else begin
			if( i_spike != 0 ) begin
				r_rst_contib <= `DATA_LENGTH'd`RESTING_CONTRIBUTION;
			end else begin
				r_rst_contib <= 0;
			end
		end
	end

	always@( posedge i_clk ) begin	// Threshold voltage contribution control
		if( i_rst == 1 ) begin
			r_thr_contib <= 0;
		end else begin
			if( o_spike != 0 ) begin
				r_thr_contib <= `DATA_LENGTH'd`THRESHOLD_CONTRIBUTION;
			end else begin
				r_thr_contib <= 0;
			end
		end
	end
					
	always@( posedge i_clk ) begin	// Resting voltage(V0) control
		if( i_rst == 1 ) begin
			r_rst_vol <= r_min_rst_vol;
		end else begin
			if( r_rst_vol >= r_max_rst_vol ) begin
				r_rst_vol <= r_rst_vol - r_rst_decay; 
			end else if( r_rst_vol <= r_min_rst_vol ) begin
				r_rst_vol <= r_min_rst_vol + r_rst_contib;
			end else begin
				r_rst_vol <= r_rst_vol + r_rst_contib - r_rst_decay;
			end
		end
	end
	
	always@( posedge i_clk ) begin	// Threshold voltage(theta) control
		if( i_rst == 1 ) begin
			r_thr_vol <= r_max_thr_vol;
		end else begin
			if( r_thr_vol >= r_max_rst_vol ) begin
				r_thr_vol <= r_max_thr_vol - r_thr_contib;
			end else if( r_thr_vol <= r_min_thr_vol ) begin
				r_thr_vol <= r_thr_vol + r_thr_growth;
			end else begin
				r_thr_vol <= r_thr_vol - r_thr_contib + r_thr_growth;
			end
		end
	end
endmodule













































