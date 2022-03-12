"""
python tb_gen_posit_2_float.py -n 16 -es 1 --no-shuffle-random --num-tests 100 | pbcopy
"""
from hardposit import from_bits
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


c = ""
for i in range(NUM_RANDOM_TEST_CASES):
    bits = int(random.random() * (1 << (N - 1)))
    p = from_bits(bits, N, ES)

    f64_obj = F64(x_f64=p.eval())

    c += f"posit = {N}'d{p.to_bits()}; "

    float_obj = F64(x_f64=p.eval())

    c += f'ascii_x = "{float_obj.eval()}"; '
    c += f'ascii_exp = "{f64_obj.exp - f64_obj.EXP_BIAS}"; '
    c += f'ascii_frac = "{f64_obj.mant}"; '
    c += f"float_bits_expected = {f64_obj.bits}; "

    c += "#10; \n"


print(c)
