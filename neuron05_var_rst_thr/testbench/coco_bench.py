############################################################################
## Cocotb testbench for neuron03 => Spike initiation model
##
## designed by Huiseong Noh
## File created : 2021-03-17
## Last edit : 2021-03-20
############################################################################

############################################################################
## Info.
## It is testbench for DUT by python cocotb library.
## Spike initiation model => threshold variation
############################################################################

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
import numpy as np
import os

@cocotb.test() #Fixed, it can enable the underlying def:coco_bench_neuron03
async def coco(dut):
	# Reset the circuit
    clock = Clock(dut.i_clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    await FallingEdge(dut.i_clk)  # Synchronize with the clock
    dut.i_rst <= 1
    for i in range(10):
        await FallingEdge(dut.i_clk)
    dut.i_rst <= 0
    dir_path = os.path.dirname(os.path.realpath(__file__))

    time = 10000	
    ran_val1 = (2**32)//5
    ran_val2 = (2**32)//4
    temp_input_value		= np.zeros(time)
    temp_internal_voltage	= np.zeros(time)
    temp_output_spike		= np.zeros(time)
    temp_rst_vol			= np.zeros(time)
    temp_thr_vol			= np.zeros(time)
    
    for i in range(time):
        if i%250==0 and not 250<=i<=1000 and not 4000<i<=5000:
            value = random.randint(ran_val1,ran_val2)
        else:
            value = 0
        dut.i_spike <= value

        await FallingEdge(dut.i_clk) # When the clock is falling, check the output value
        temp_input_value[i]		 = value
        temp_internal_voltage[i] = dut.o_internal_state.value.integer
        temp_output_spike[i]	 = dut.o_spike.value.integer
        temp_rst_vol[i]			 = dut.o_rst_vol.value.integer
        temp_thr_vol[i]			 = dut.o_thr_vol.value.integer
        
    np.save('./data_numpy/input_spikes.npy'		,temp_input_value)
    np.save('./data_numpy/internal_voltage.npy' ,temp_internal_voltage)
    np.save('./data_numpy/output_spikes.npy'	,temp_output_spike)
    np.save('./data_numpy/rst_vol.npy'			,temp_rst_vol)
    np.save('./data_numpy/thr_vol.npy'			,temp_thr_vol)

