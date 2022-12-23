import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from hardposit import from_bits,from_double


values = [1.0,2.0,3.0,4.0,5.0,1.0,2.0,3.0,4.0,5.0]

# clk,
# rst,
# valid_in,
# in1,
# in2,
# op,
# out,
# valid_o


@cocotb.test()
async def test_simple(dut):
    dut.in1.value = 1
    dut.in2.value = 1
    dut.op.value = 0
    print (dut.out.value)
    