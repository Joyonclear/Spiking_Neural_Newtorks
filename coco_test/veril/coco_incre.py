# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge


@cocotb.test()
async def test_incre(dut):

    clock = Clock(dut.clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    await FallingEdge(dut.clk)  # Synchronize with the clock
    for i in range(20):
        val1 = random.randint(0, 4)
        val2 = random.randint(0, 4)
        dut.add <= val1
        dut.add2 <= val2
        print("value1 = ",end='')
        print(val1, end=' ')

        await FallingEdge(dut.clk)
        print("result = ",end='')
        print(dut.out1.value.integer,end='   ')
        print("value2 = ",end='')
        print(val2, end=' ')
        print("output = ",end='')
        print(dut.out.value.integer)
		#print(type(dut.out.value))


#	for i in range(10):
#       val = random.randint(0, 1)
#       dut.d <= val  # Assign the random value val to the input port d
#       await FallingEdge(dut.clk)
      	
