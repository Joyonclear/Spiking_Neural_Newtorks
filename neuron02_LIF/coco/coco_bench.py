# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
time = 10000
import random
import cocotb
import csv
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
import numpy as np
import os
@cocotb.test()
async def coco_bench_neuron02(dut):

    clock = Clock(dut.i_clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    await FallingEdge(dut.i_clk)  # Synchronize with the clock
    dut.i_rst <= 1
    for i in range(10):
        await FallingEdge(dut.i_clk)
    dut.i_rst <= 0
    f = open('simulation.csv','w',newline='')
    wr = csv.writer(f)
    wr.writerow(['time','input','state_LID','output_LID','state_EXD','output_EXD'])
    dir_path = os.path.dirname(os.path.realpath(__file__))

    val_sv = np.zeros(time)
    lid_val_sv = np.zeros(time)
    lid_sp_sv = np.zeros(time)
    exd_val_sv = np.zeros(time)
    exd_sp_sv = np.zeros(time)
    for i in range(time):
        if i%250==0:
            val = random.randint(700000000,800000000)
        else:
            val = 0
        dut.i_spike <= val

        await FallingEdge(dut.i_clk) # When the clock is falling, check the output value
        val_sv[i]=val
        lid_val_sv[i]=dut.o_internal_state_lid.value.integer
        lid_sp_sv[i]= dut.o_spike_lid.value.integer
        exd_val_sv[i]=dut.o_internal_state_exd.value.integer
        exd_sp_sv[i]= dut.o_spike_exd.value.integer
        
        wr.writerow(['time',val,dut.o_internal_state_lid.value.integer,dut.o_spike_lid.value.integer,dut.o_internal_state_exd.value.integer,dut.o_spike_exd.value.integer])
    np.save('val.npy',val_sv)
    np.save('lid_val.npy',lid_val_sv)
    np.save('lid_sp.npy',lid_sp_sv)
    np.save('exd_val.npy',exd_val_sv)
    np.save('exd_sp.npy',exd_sp_sv)
#        print(dut.o_internal_state_lid.value.integer,end='')
#       print('   input_spike=',end='')
#       print(val,end='')
#       print('   ouput_spike=',end='')
#       print(dut.o_spike_lid.value.integer)

    f.close()    
