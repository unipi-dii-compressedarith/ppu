"""
$ python tb_gen_pipelined.py | pbcopy

then paste it to tb_pipelined
"""

import random
import argparse

parser = argparse.ArgumentParser(description="Generate test benches")

parser.add_argument(
    "--shuffle-random",
    dest="shuffle_random",
    action="store_true",
    help="Shuffle random",
)
parser.add_argument(
    "--no-shuffle-random",
    dest="shuffle_random",
    action="store_false",
    help="Shuffle random",
)
parser.set_defaults(shuffle_random=False)


parser.add_argument(
    "--num-tests", "-nt", type=int, required=True, help="Num test cases"
)

parser.add_argument("--num-bits", "-n", type=int, required=True, help="Num posit bits")
parser.add_argument("--float-size", "-f", type=int, required=True, help="Float size")

args = parser.parse_args()

N = args.num_bits
F = args.float_size
NUM_RANDOM_TEST_CASES = args.num_tests

if args.shuffle_random == False:
    random.seed(4)


ops = {
    0: "ADD",
    1: "SUB",
    2: "MUL",
    3: "DIV",
    4: "FLOAT_TO_POSIT",
    5: "POSIT_TO_FLOAT",
}

c = ""
for i in range(NUM_RANDOM_TEST_CASES):
    valid_in = int(random.random() > 0.1)  # 90% of the time
    match F:
        case 0:
            op = ops[int(random.random() * (len(ops) -2))]  # ops equally distributed
        case _:
            op = ops[int(random.random() * len(ops))]  # ops equally distributed
            
    in1 = int(random.random() * ((1 << N) - 1))
    in2 = int(random.random() * ((1 << N) - 1))
    delay = int(random.random() * 12 + 3)  # between 3 and 15
    if not valid_in:
        op = "'bz"
        in1 = "'bz"
        in2 = "'bz"

    if op == "FLOAT_TO_POSIT":
        in1 = int(random.random() * ((1 << F) - 1))
        in2 = "'bx"

    if op == "POSIT_TO_FLOAT":
        in1 = "'bx"

    c += f"""
ppu_valid_in = {valid_in};
ppu_op = {op};
ppu_in1 = {in1};
ppu_in2 = {in2};
#{delay};

    """

print(c)
