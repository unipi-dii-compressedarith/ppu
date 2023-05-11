import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.result import TestFailure
from cocotb.queue import Queue
import random
## 
from hardposit import from_bits, from_double
import fixed2float as fi
import softposit as sp

TEST_SIZE = 5
N, ES = 16, 1

MAX_VAL = (1 << N) - 1

test_data_in1 = list(map(lambda x: random.randint(0, MAX_VAL), range(TEST_SIZE)))
test_data_in2 = list(map(lambda x: random.randint(0, MAX_VAL), range(TEST_SIZE)))
test_data_out = [0] * TEST_SIZE

# softposit
#expected_out = list(map(lambda bits1, bits2: (sp.posit16(bits=bits1) * sp.posit16(bits=bits2)).toHex(), test_data_in1, test_data_in2))

# hardposit
expected_out = list(map(lambda bits1, bits2: (from_bits(bits1, N, ES) * from_bits(bits2, N, ES)).to_bits(), test_data_in1, test_data_in2))


@cocotb.test()
async def queue_test(dut):
  """
  Test that the output of the DUT matches the expected output.
  """
  # Create input and output queues
  input_queue1 = Queue(maxsize=10)
  input_queue2 = Queue(maxsize=10)
  output_queue = Queue(maxsize=10)

  # Start the clock
  clock = Clock(dut.clk_i, 10, units="ns")
  cocotb.start_soon(clock.start())

  # Reset the DUT
  dut.rst_i.value = 1
  await RisingEdge(dut.clk_i)
  dut.rst_i.value = 0


  # Push test data into the input queue
  for (data1, data2) in zip(test_data_in1, test_data_in2):
    input_queue1.put_nowait(data1)
    input_queue2.put_nowait(data2)

  print(f"{input_queue1=}")
  print(f"{input_queue2=}")
  print(f"{output_queue=}")


  # Wait for data to be processed by the DUT
  
  while output_queue.qsize() != len(test_data_in1):

    print(f"{output_queue.qsize()=}")

    # if not dut.ready:
    #   await RisingEdge(dut.clk_i)
    # else:
    try:
      dut.operand1_i.value = input_queue1.get_nowait()
      dut.operand2_i.value = input_queue2.get_nowait()
      dut.op_i.value = 2 # mul
      dut.in_valid_i.value = 1
    except cocotb.queue.QueueEmpty:
      pass

    await RisingEdge(dut.clk_i)
    if dut.out_valid_o.value == 1:
      print(f"{dut.result_o.value=}")
      output_queue.put_nowait(dut.result_o.value)

  
  print(f"{output_queue=}")

  # Verify the output of the DUT
  while not output_queue.empty():

    output_queue.get_nowait()
    
    expected = expected_out.pop(0)
    print(f"{expected=}")
    out = output_queue.get_nowait()
    
    assert out == expected, f"output = {out}, expected = {expected}"

  # Wait a few extra clock cycles for good measure
  await Timer(10, units="ns")
