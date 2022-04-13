"""
Wed Apr 13 11:21:20 CEST 2022
=============================================

$ python tb_gen_pipelined_long.py --num-tests $(NUM_TESTS_PPU_PIPELINED) -n $(N) -f $(F) --shuffle-random | pbcopy

then paste it to tb_pipelined
"""

from typing import Tuple
import argparse

parser = argparse.ArgumentParser(description="Generate test benches")

parser.add_argument(
    "--most-diverse",
    dest="input_diverseness",
    action="store_true",
    help="Input diverseness",
)
parser.add_argument(
    "--least-diverse",
    dest="input_diverseness",
    action="store_false",
    help="Input diverseness",
)
parser.set_defaults(input_diverseness=False)


parser.add_argument(
    "--num-tests", "-nt", type=int, required=True, help="Num test cases"
)

parser.add_argument("--num-bits", "-n", type=int, required=True, help="Num posit bits")
parser.add_argument("--float-size", "-f", type=int, required=True, help="Float size")

args = parser.parse_args()

N = args.num_bits
F = args.float_size
NUM_RANDOM_TEST_CASES = args.num_tests



#############################################


def generate_gray_list(my_val):
    if my_val <= 0:
        return
    my_list = list()
    my_list.append("0")
    my_list.append("1")
    i = 2
    j = 0
    while True:
        if i >= 1 << my_val:
            break
        for j in range(i - 1, -1, -1):
            my_list.append(my_list[j])
        for j in range(i):
            my_list[j] = "0" + my_list[j]
        for j in range(i, 2 * i):
            my_list[j] = "1" + my_list[j]
        i = i << 1

    for seq in my_list:
        yield int(seq, 2)



DELAY = 10  # delay

ops = {
    0: "ADD",
    1: "SUB",
    2: "MUL",
    3: "DIV",
    4: "FLOAT_TO_POSIT",
    5: "POSIT_TO_FLOAT",
}


# ALTERNATING_BITS 1010101010101010
def gen_alternating_bits_sequence(size: int) -> Tuple[int]:
    num = 0
    for i in range(size):
        if i % 2:
            num |= 1 << i
    return num, ~num & ((1 << N) - 1)



num = gen_alternating_bits_sequence(N)

c = ""
for iter in range(len(ops) - 2):
    op = ops[iter]
    iter_gray = generate_gray_list(N) # reset generator
    for i in range(NUM_RANDOM_TEST_CASES):
        valid_in = 1

        if args.input_diverseness == True:
            """contiguous operands are most dissimilar to one another"""
            # i%2 alternative picks  1010..010 and its complementary at each cycles so that the bits difference is the largest
            in1 = num[i % 2]
            in2 = num[(i + 1) % 2]  # the complementary of in1
        elif args.input_diverseness == False:
            """contiguous operands are most similar to one another: Gray sequence"""
            in1 = next(iter_gray)
            in2 = 1 << (N - 2)  # some fixed number
        else:
            raise Exception("wrong arg")

        # delay = int(random.random() * 12 + 3)  # between 3 and 15
        delay = DELAY

        # if op == "FLOAT_TO_POSIT":
        #     in1 = int(random.random() * ((1 << F) - 1))
        #     in2 = "'bx"

        # if op == "POSIT_TO_FLOAT":
        #     in1 = "'bx"

        c += f"""ppu_valid_in = {valid_in}; ppu_op = {op}; ppu_in1 = {in1}; ppu_in2 = {in2}; #{delay}; \n"""

    valid_in = 0
    delay = 100 * DELAY
    c += f"""ppu_valid_in = {valid_in}; ppu_op = 'hz; #{delay};"""


print(c)
