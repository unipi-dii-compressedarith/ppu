"""
python tb_gen_float_2_posit.py -n 16 -es 1 -f 32 --no-shuffle-random --num-tests 100 | pbcopy
"""
from hardposit import from_double
from hardposit.f64 import F64
from hardposit.f32 import F32
from hardposit.f16 import F16
import argparse
import random

parser = argparse.ArgumentParser(description="Generate test benches")

parser.add_argument(
    "--num-tests", "-nt", type=int, required=True, help="Num test cases"
)

parser.add_argument("--num-bits", "-n", type=int, required=True, help="Num posit bits")

parser.add_argument("--es-size", "-es", type=int, required=True, help="Exponent size")

parser.add_argument("--float-size", "-f", type=int, required=True, help="Float size")

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


N, ES, F = args.num_bits, args.es_size, args.float_size
NUM_RANDOM_TEST_CASES = args.num_tests


for i in range(NUM_RANDOM_TEST_CASES):
    # x is distributed between -A/2 and A/2
    A = 150
    x = random.random() * A - A / 2

    match F:
        case 64:
            float_obj = F64(x_f64=x)
        case 32:
            float_obj = F32(x_f32=x)
        case 16:
            float_obj = F16(x_f16=x)
        case _:
            raise Exception(
                "Float size not supported. Consider passing `-f 64` or `-f 32` or `-f 16`."
            )

    p = from_double(x, N, ES)

    print(f"float_bits = {float_obj.bits}; ")
    print(f'ascii_x = "{x}"; ')
    print(f'ascii_exp = "{float_obj.exp - float_obj.EXP_BIAS}"; ')
    print(f'ascii_frac = "{float_obj.mant}"; ')
    print(f"posit_expected = {N}'d{p.to_bits()}; ")
    print("#10; \n")
