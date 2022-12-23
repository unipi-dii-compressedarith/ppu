# test_dff.py

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from hardposit import from_bits,from_double


values = [1.0,2.0,3.0,4.0,5.0,1.0,2.0,3.0,4.0,5.0]

@cocotb.test()
async def test_simple(dut):
    dut.te1.value = 1
    dut.te2.value = 1
    dut.mant1.value = 1
    dut.mant2.value = 1

    print (dut.te_out.value)
    print (dut.mant_out.value)
    