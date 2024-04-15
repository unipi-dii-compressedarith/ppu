# test_my_design.py (extended)

import cocotb
from cocotb.triggers import FallingEdge, Timer
from hardposit import *

'''
0  ADD,
1  SUB,
2  MUL,
3  DIV,
4  FMADD_S, // FMADD start: accumulator is initialized
5  FMADD_C, // FMADD continue: accumulator maintains its value
6  F2P,
7  P2F
'''

glob_dut = None

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
        dut.clk_i.value = 0
        await Timer(10, units="ns")
        dut.clk_i.value = 1
        await Timer(10, units="ns")

def log_posit(varn, res, n, es, dut):
    try:
        dut._log.info("%s is %s", varn, from_bits(res,n,es))
    except ValueError:
        dut._log.info("[VALUE ERROR] %s", res )

def log_div_unit(dut):
    #dut._log.info("%s", dut.ppu.core_ops.core_div.mant_o.value)    
    divm = dut.ppu_inst.ppu_core_ops_inst.fir_ops_inst.core_op_inst.core_div_inst
    print(dir(divm))
    dut._log.info("lto: %s", divm.mant_div_less_than_one )
    dut._log.info("manto: %s", divm.mant_o )


@cocotb.test()
async def coco_test_sum(dut):
    """Try accessing the design."""
    await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    o1 = 0x2120
    o2 = 0x2030
    n = 16
    es = 1
    await Timer(10, units="ns")  # wait a bit
    dut.operand1_i.value = o1
    log_posit("op1", o1, n,es, dut )
    dut.operand2_i.value = o2
    log_posit("op2", o2, n,es, dut)
    dut.op_i.value = 0x3
    dut.in_valid_i.value = 0x1
    await FallingEdge(dut.clk_i)  # wait for falling edge/"negedge"
    log_div_unit(dut)
    log_posit("result", dut.result_o.value, n,es, dut)
    dut._log.info("exp: %s", from_bits(o1,n,es)/from_bits(o2,n,es))

    dut._log.info("DONE")
