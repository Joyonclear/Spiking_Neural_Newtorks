//#########################################################################################
//## Neuron design Num.07 => code rearragement and clearness
//## 
//## designed by Huiseong Noh
//## File created : 2021-05-11
//## Last edit : 2021-05-11
//###########################################################################################

//###########################################################################################
//## Info.
//## It is DUT(Design Under Test)(Verilog module).
//## 1. The input contribution is gradually accumulated to internal states.
//## 2. Exponential decay of internal states
//## 3. Adaptive threshold by output spikes( short-term )
//## 4. Adaptive resting voltage by output spikes( long-term )
//## 5. Absolute refractory ( counter, blocking input spikes during counts )
//###########################################################################################

`include "../parameter.h"
`timescale 1us / 100ns

module neuron07#(
	parameter   DATA_LENGTH				= `H_INTERNAL_VOLTAGE_RESOULTION_BITS,
	// Input Accumulation
	parameter	TAU_BUF					= `H_TAU_BUF,
	// Exponential Decay
	parameter	TAU_INT					= `H_TAU_INT,
	// Adaptive Threshold
	parameter	MAX_THRESHOLD_VOLTAGE	= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_MAX_THRESHOLD_VOLTAGE_RATIO,
	parameter	MIN_THRESHOLD_VOLTAGE	= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_MIN_THRESHOLD_VOLTAGE_RATIO,
	parameter	THRESHOLD_CONTRIBUTION	= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_THRESHOLD_CONTRIBUTION_RATIO,
	parameter	TAU_THR					= `H_TAU_THR,
	// Adaptive Resting Voltage
	parameter	MAX_RESTING_VOLTAGE		= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_MAX_RESTING_VOLTAGE_RATIO,
	parameter	MIN_RESTING_VOLTAGE		= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_MIN_RESTING_VOLTAGE_RATIO,
	parameter	RESTING_CONTRIBUTION	= 2**`H_INTERNAL_VOLTAGE_RESOULTION_BITS*`H_RESTING_CONTRIBUTION_RATIO,
	parameter	TAU_RST					= `H_TAU_RST,
	// Refractory
	parameter	CLK_COUNT				= `H_CLK_COUNT)(
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
	
	reg			[DATA_LENGTH-1:0]	r_input_buffer; // Buffer which has input spikes summation
	reg			[DATA_LENGTH-1:0]	r_input_spike; // Contribution which is applied to neuron directly
	reg			[DATA_LENGTH-1:0]	r_refractory_counter;

	reg			[DATA_LENGTH-1:0]	r_int_vol;	//register insternal voltage
	reg			[DATA_LENGTH-1:0]	r_rst_vol;	//register resting voltage
    reg			[DATA_LENGTH-1:0]	r_thr_vol;	//register threshold voltage
	
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

	always@( posedge i_clk ) begin	// Spike Accumulation. Gradual contribution control 
		if( i_rst == 1 ) begin
			r_input_buffer <= 0;
		end else begin
			if( r_refractory_counter == 0 ) begin
				r_input_buffer <= r_input_buffer + i_spike - r_input_buffer/TAU_BUF;	
			end else begin
				r_input_buffer <= 0;
			end
		end
	end

	always@( posedge i_clk ) begin	// Refractory. Controlling the input volatage by counter
		if( i_rst == 1 ) begin
			r_input_spike <= 0;
			r_refractory_counter <= 0;
		end else begin
			if( r_int_vol < r_thr_vol ) begin
				if( r_refractory_counter == 0 ) begin
					r_input_spike <= r_input_buffer/TAU_BUF;
				end else begin
					r_input_spike <= 0;
					r_refractory_counter <= r_refractory_counter - 1;
				end
			end else begin
				r_input_spike <= 0;
				r_refractory_counter <= CLK_COUNT; // ######clock cycle delay
			end
		end
	end

    always@( posedge i_clk ) begin	// Neuron's internal state control
		if( i_rst == 1 ) begin
			r_int_vol <= r_rst_vol;
		end else begin
			if( r_int_vol < r_thr_vol ) begin
				if( r_int_vol <= r_rst_vol ) begin
					r_int_vol <= r_int_vol + (r_rst_vol - r_int_vol)/TAU_RST + r_input_spike;
				end else begin
					r_int_vol <= r_int_vol - (r_int_vol-r_rst_vol)/TAU_RST + r_input_spike;
				end
			end else begin
				r_int_vol <= r_rst_vol - RESTING_CONTRIBUTION + (MAX_RESTING_VOLTAGE - r_rst_vol)/TAU_RST;
			end
		end
	end
		
	always@( posedge i_clk ) begin	// Resting voltage(V0) control
		if( i_rst == 1 ) begin
			r_rst_vol <= MAX_RESTING_VOLTAGE;
		end else begin
			if( r_rst_vol >= MAX_RESTING_VOLTAGE ) begin
				if( r_int_vol < r_thr_vol ) begin
					r_rst_vol <= MAX_RESTING_VOLTAGE; 
				end else begin
					r_rst_vol <= MAX_RESTING_VOLTAGE - RESTING_CONTRIBUTION; 
				end
			end else if( r_rst_vol < MIN_RESTING_VOLTAGE ) begin
				r_rst_vol <= MIN_THRESHOLD_VOLTAGE;
			end else begin
				if( r_int_vol < r_thr_vol ) begin
					r_rst_vol <= r_rst_vol + (MAX_RESTING_VOLTAGE - r_rst_vol)/TAU_RST;
				end else begin
					r_rst_vol <= r_rst_vol - RESTING_CONTRIBUTION + (MAX_RESTING_VOLTAGE - r_rst_vol)/TAU_RST;
				end
			end
		end
	end
	
	always@( posedge i_clk ) begin	// Threshold voltage(theta) control
		if( i_rst == 1 ) begin
			r_thr_vol <= MIN_THRESHOLD_VOLTAGE;
		end else begin
			if( r_thr_vol > MAX_THRESHOLD_VOLTAGE ) begin
				r_thr_vol <= MAX_THRESHOLD_VOLTAGE;
			end else if( r_thr_vol <= MIN_THRESHOLD_VOLTAGE ) begin
				if( r_int_vol < r_thr_vol ) begin
					r_thr_vol <= MIN_THRESHOLD_VOLTAGE;
				end else begin
					r_thr_vol <= MIN_THRESHOLD_VOLTAGE + THRESHOLD_CONTRIBUTION;
				end
			end else begin
				if( r_int_vol < r_thr_vol ) begin
					r_thr_vol <= r_thr_vol - (r_thr_vol - MIN_THRESHOLD_VOLTAGE)/TAU_THR;
				end else begin
					r_thr_vol <= r_thr_vol + THRESHOLD_CONTRIBUTION - (r_thr_vol - MIN_THRESHOLD_VOLTAGE)/TAU_THR;
				end
			end
		end
	end
endmodule
























