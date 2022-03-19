"""
python tb_gen_posit_2_float.py -n 16 -es 1 -f 32 --no-shuffle-random --num-tests 100 | pbcopy
"""
from hardposit import from_bits
from hardposit.float import F64, F32, F16
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


c = ""
for i in range(NUM_RANDOM_TEST_CASES):
    bits = int(random.random() * (1 << (N - 1)))
    p = from_bits(bits, N, ES)

    match F:
        case 64:
            float_obj = F64(x_f64=p.eval())
        case 32:
            float_obj = F32(x_f32=p.eval())
        case 16:
            float_obj = F16(x_f16=p.eval())
        case _:
            raise Exception(
                "Float size not supported. Consider passing `-f 64` or `-f 32` or `-f 16`."
            )

    c += f"posit = {N}'d{p.to_bits()}; "

    float_obj = F64(x_f64=p.eval())

    c += f'ascii_x = "{float_obj.eval()}"; '
    c += f'ascii_exp = "{float_obj.exp - float_obj.exp_bias}"; '
    c += f'ascii_frac = "{float_obj.mant}"; '
    c += f"float_bits_expected = {float_obj.bits}; "
    c += f'assert (float_bits === float_bits_expected) else $display("ERROR: pf2({p.to_bits()}) = 0x%h != {float_obj.bits}", float_bits);\n\n'

    c += "#10; \n"


print(c)
