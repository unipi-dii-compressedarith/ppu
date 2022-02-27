"""
python tb_gen_comparisons.py -n 16 -es 1 --no-shuffle-random --num-tests 100 | pbcopy
"""
from hardposit import from_double
from posit_playground.f64 import F64
import argparse
import random

parser = argparse.ArgumentParser(description="Generate test benches")

parser.add_argument(
    "--num-tests", "-nt", type=int, required=True, help="Num test cases"
)

parser.add_argument("--num-bits", "-n", type=int, required=True, help="Num posit bits")

parser.add_argument("--es-size", "-es", type=int, required=True, help="Num posit bits")

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

args = parser.parse_args()


if args.shuffle_random == False:
    random.seed(4)


N, ES = args.num_bits, args.es_size
NUM_RANDOM_TEST_CASES = args.num_tests


for i in range(NUM_RANDOM_TEST_CASES):
    # x is distributed between -A/2 and A/2
    A = 150
    x = random.random() * A - A/2

    f64_obj = F64(x_f64=x)
    p = from_double(x, N, ES)
    
    print(f"float_bits = {f64_obj.bits};")
    print(f"ascii_x = \"{x}\";")
    print(f"ascii_exp = \"{f64_obj.exp - f64_obj.EXP_BIAS}\";")
    print(f"ascii_frac = \"{f64_obj.mant}\";")
    print(f"posit_expected = {N}'d{p.to_bits()};")
    print("#10;\n")
