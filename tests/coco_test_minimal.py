# test_my_design.py (extended)

import cocotb
from cocotb.triggers import FallingEdge, Timer


async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
        dut.clk_i.value = 0
        await Timer(10, units="ns")
        dut.clk_i.value = 1
        await Timer(10, units="ns")


@cocotb.test()
async def coco_test_minimal(dut):
    """Try accessing the design."""
    print(dut)
    await cocotb.start(generate_clock(dut))  # run the clock "in the background"

    await Timer(10, units="ns")  # wait a bit
    await FallingEdge(dut.clk_i)  # wait for falling edge/"negedge"
    
    dut._log.info("DONE")
