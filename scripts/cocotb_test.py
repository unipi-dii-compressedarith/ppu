# test_dff.py

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from hardposit import from_bits,from_double

#	clk,
#	rst,
#	ppu_valid_in,
#	ppu_in1,
#	ppu_in2,
#	ppu_op,
#	ppu_out,
#	ppu_valid_o

values = [1.0,2.0,3.0,4.0,5.0,1.0,2.0,3.0,4.0,5.0]

@cocotb.test()
async def test_dff_simple(dut):
    """ Test that d propagates to q """

    clock = Clock(dut.clk, 1, units="ns")  # Create a 10us period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock
    dut.rst.value = 1
    dut.ppu_valid_in.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for i in range(10):
        value = values[i]
        for a in range(3):
            match a:                
                case 0:
                    posit_val = from_double(value,8,0);
                    posit_bits = posit_val.to_bits()
                    dut.ppu_in1.value = posit_bits
                    dut.ppu_in2.value = posit_bits
                    dut.ppu_valid_in.value = 1
                    dut.ppu_op.value = 0 # ADD

            await RisingEdge(dut.clk)

        if dut.ppu_valid_o.value.binstr.isdigit() and dut.ppu_valid_o.value.integer == 1: # is valid
            posit_bits = dut.ppu_out.value.integer
            posit_val = from_bits(posit_bits,8,0).eval()
            val = values[i-1]
            assert posit_val == val + val

