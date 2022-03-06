"""
pip install hardposit

e.g.:
    python tb_gen.py --num-tests 500 --operation ppu -n 16 -es 1 --no-shuffle-random
"""

import argparse
import random
import datetime
import enum
import pathlib
import math

# from posit_playground import from_bits
from hardposit import from_bits, from_double
from posit_playground.utils import get_bin, get_hex
from posit_playground.f64 import F64

LJUST = 25
X = "'bX"


def clog2(x):
    return math.ceil(math.log2(x))


class Tb(enum.Enum):
    MUL = "mul"
    ADD = "add"
    SUB = "sub"
    DIV = "div"
    MUL_CORE = "mul_core"
    DECODE = "decode"
    ENCODE = "encode"
    PPU = "ppu"
    PACOGEN = "pacogen"
    FLOAT_TO_POSIT = "float_to_posit"
    POSIT_TO_FLOAT = "posit_to_float"

    def __str__(self):
        return self.value


operations = {Tb.MUL: "*", Tb.ADD: "+", Tb.SUB: "-", Tb.DIV: "/", Tb.PACOGEN: "/"}

parser = argparse.ArgumentParser(description="Generate test benches")
parser.add_argument(
    "--operation",
    type=Tb,
    choices=list(Tb),
    required=True,
    help="Type of test bench: adder/multiplier/etc",
)

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

parser.add_argument("--es-size", "-es", type=int, required=True, help="Num posit bits")

args = parser.parse_args()


N, ES = args.num_bits, args.es_size
NUM_RANDOM_TEST_CASES = args.num_tests
S = clog2(N)

if args.shuffle_random == False:
    random.seed(4)


def single_arg_func(c, op):
    c += "`ifdef FLOAT_TO_POSIT\n"
    c += f"out_ground_truth = 'bz;\n"
    if op == Tb.FLOAT_TO_POSIT:
        c += f"op = {op.name};\n"
        c += f'op_ascii = "{op.name}";\n\n'
        for _ in range(NUM_RANDOM_TEST_CASES):
            # x is distributed between -A/2 and A/2
            A = 150
            x = random.random() * A - A/2

            float_obj = F64(x_f64=x)
            p = from_double(x, N, ES)

            c += f"in1 = {float_obj.bits}; "
            c += f"ascii_x = \"{x}\"; "
            c += f"ascii_exp = \"{float_obj.exp - float_obj.EXP_BIAS}\"; "
            c += f"ascii_frac = \"{float_obj.mant}\"; "
            c += f"out_ground_truth = {N}'d{p.to_bits()}; "
            c += f"out_expected_ascii = \"{p.eval()}\"; "
            #c += f"assert (pout === pout_ground_truth) else $display("ERROR: 0x64c4 / 0x6436 = 0x%h != 0x40ba", pout);"
            c += "#10; \n"
    elif op == Tb.POSIT_TO_FLOAT:
        c += f"op = {op.name};\n"
        c += f'op_ascii = "{op.name}";\n\n'
        c += f"in1 = 'bz;\n\n"
        for _ in range(NUM_RANDOM_TEST_CASES):
            bits = int(random.random() * (1 << (N-1)))
            p = from_bits(bits, N, ES)

            f64_obj = F64(x_f64 = p.eval())
            
            c += f"in2 = {N}'d{p.to_bits()}; "

            float_obj = F64(x_f64 = p.eval())

            c += f"ascii_x = \"{float_obj.eval()}\"; "
            c += f"ascii_exp = \"{f64_obj.exp - f64_obj.EXP_BIAS}\"; "
            c += f"ascii_frac = \"{f64_obj.mant}\"; "
            c += f"out_ground_truth = {f64_obj.bits}; "
            c += "#10; \n"
    else:
        raise Exception("wrong arg?")
    c += "`endif\n"
    return c


def func(c, op, list_a, list_b):
    # c += f"if (N == {N} && {ES} == 2) begin\n"

    if op == Tb.PACOGEN:
        c += f"\top = DIV;\n"
        c += f'\top_ascii = "DIV";\n\n'
    else:
        c += f"op = {op.name};\n"
        c += f'op_ascii = "{op.name}";\n\n'

    for counter, (a, b) in enumerate(zip(list_a, list_b)):
        p1 = from_bits(a, N, ES)
        p2 = from_bits(b, N, ES)

        if op == Tb.MUL:
            pout = p1 * p2
        elif op == Tb.ADD:
            pout = p1 + p2
        elif op == Tb.SUB:
            pout = p1 - p2
        elif op == Tb.DIV:
            pout = p1 / p2
        elif op == Tb.PACOGEN:
            pout = p1 / p2
        else:
            raise Exception("wrong op?")

        c += f"{'test_no ='.ljust(LJUST)} {counter+1};\n\t"
        c += f"{'in1 ='.ljust(LJUST)} {N}'h{p1.to_hex(prefix=False)};\n\t"
        c += f"""{'in1_ascii ='.ljust(LJUST)} "{p1.eval()}";\n\t"""
        c += f"{'in2 ='.ljust(LJUST)} {N}'h{p2.to_hex(prefix=False)};\n\t"
        c += f"""{'in2_ascii ='.ljust(LJUST)} "{p2.eval()}";\n\t"""
        c += f"""{'out_gt_ascii ='.ljust(LJUST)} "{pout.eval()}";\n\t"""
        c += f"{'out_ground_truth ='.ljust(LJUST)} {N}'h{pout.to_hex(prefix=False)};\n\t"
        if op != Tb.DIV and op != Tb.PACOGEN:
            c += f"{'pout_hwdiv_expected ='.ljust(LJUST)} {N}'hz;\n\t"
        else:
            if N <= 16:  # to be lifted later on when __hwdiv__ will support P32
                c += f"{'pout_hwdiv_expected ='.ljust(LJUST)} {N}'h{(p1.__hwdiv__(p2)).to_hex(prefix=False)};\n\t"
            else:
                c += f"{'pout_hwdiv_expected ='.ljust(LJUST)} {N}'hz;\n\t"
        c += f"#10;\n\t"
        if op == Tb.PACOGEN:
            c += f'assert (pout_pacogen === out_ground_truth) else $display("PACOGEN_ERROR: {p1.to_hex(prefix=True)} {operations[op]} {p2.to_hex(prefix=True)} = 0x%h != {pout.to_hex(prefix=True)}", pout_pacogen);\n\n'
            c += f'assert (pout_ppu_core_ops === out_ground_truth) else $display("ppu_core_ops_ERROR: {p1.to_hex(prefix=True)} {operations[op]} {p2.to_hex(prefix=True)} = 0x%h != {pout.to_hex(prefix=True)}", pout_ppu_core_ops);\n\n'
        else:
            c += f'assert (out === out_ground_truth) else $display("ERROR: {p1.to_hex(prefix=True)} {operations[op]} {p2.to_hex(prefix=True)} = 0x%h != {pout.to_hex(prefix=True)}", out);\n\n'
    c += f'$display("Total tests cases: {len(list_a)}");\n'
    # c += "end\n"
    return c


if __name__ == "__main__":

    c = f"""\t/*-------------------------------------+
    | autogenerated by tb_gen.py on       |
    | {datetime.datetime.now().strftime('%c')}            |
    +-------------------------------------*/\n"""

    positive_only = False
    if positive_only:
        _max = (1 << (N - 1)) - 1
    else:
        _max = (1 << (N)) - 1

    # list_a = random.sample(range(0, _max), min(NUM_RANDOM_TEST_CASES, _max))
    # list_b = random.sample(range(0, _max), min(NUM_RANDOM_TEST_CASES, _max))
    list_a = [random.randint(0, _max) for _ in range(NUM_RANDOM_TEST_CASES)]
    list_b = [random.randint(0, _max) for _ in range(NUM_RANDOM_TEST_CASES)]

    ### enforce special cases to be at the beginning
    # 0 vs any
    list_a[0] = 0
    # nan vs any
    list_a[1] = 1 << (N - 1)
    # 0 vs nan
    list_a[2], list_b[2] = 0, 1 << (N - 1)

    # any vs 0
    list_b[3] = 0
    # any vs nan
    list_b[4] = 1 << (N - 1)
    # nan vs 0
    list_a[5], list_b[5] = 1 << (N - 1), 0
    # 0 vs 0
    list_a[6], list_b[6] = 0, 0
    # x vs -x
    list_b[7] = (~list_a[7] + 1) & ((1 << N) - 1)
    # 0b10000.....001 kind of number causes errors as of 3316bd5 due to mant_len out of bound. needs more bits to be representate because it can go negative.
    list_a[8] = (1 << (N - 1)) + 1



    if args.operation == Tb.DECODE or args.operation == Tb.ENCODE:
        for (counter, a) in enumerate(list_a):
            p = from_bits(a, N, ES)

            c += f"{'test_no ='.ljust(LJUST)} {counter+1};\n"

            if p.fields.is_some:
                regime = p.fields.unwrap().regime
                reg_s, reg_len, k = regime.reg_s, regime.reg_len, regime.k
                exp = p.fields.unwrap().exp
                mant = p.mant_repr().unwrap()  # p.fields.unwrap().mant
                mant_len = p.mant_len.unwrap()
            else:
                reg_s, reg_len, k = X, X, X
                exp = X
                mant = X
                mant_len = X

            if args.operation == Tb.DECODE:
                # posit bits
                c += f"{'bits ='.ljust(LJUST)} {N}'b{p.to_bin(prefix=False)};\n"
                # sign
                c += f"{'sign_expected ='.ljust(LJUST)} {p.sign.real};\n"
                if p.fields.is_some:
                    # regime
                    c += f"{'reg_s_expected ='.ljust(LJUST)} {reg_s.real};\n"
                    c += f"{'reg_len_expected ='.ljust(LJUST)} {reg_len};\n"
                    c += f"{'k_expected ='.ljust(LJUST)} {k};\n"
                    c += f"{'k_is_pos ='.ljust(LJUST)} {(p.fields.unwrap().regime.k > 0).real};\n"
                    # exponent
                    if ES > 0:
                        c += f"{'exp_expected ='.ljust(LJUST)} {ES}'b{get_bin(exp, ES, prefix=False)};\n"
                    # mantissa
                    c += f"{'mant_expected ='.ljust(LJUST)} {N}'b{get_bin(mant, N, prefix=False)};\n"
                    c += f"{'mant_len_expected ='.ljust(LJUST)} {mant_len};\n"
                else:
                    pass
                c += f"{'is_special_expected ='.ljust(LJUST)} {(p.is_zero or p.is_nan).real};\n"
            elif args.operation == Tb.ENCODE:
                c += f"{'posit_expected ='.ljust(LJUST)} {N}'h{p.to_hex(prefix=False)};\n"
                ### sign
                c += f"{'sign ='.ljust(LJUST)} {p.sign.real};\n"
                if p.fields.is_some:
                    ### regime
                    c += f"{'reg_len ='.ljust(LJUST)} {reg_len.real};\n"
                    c += f"{'k ='.ljust(LJUST)} {k};\n"
                    ### exponent
                    if ES > 0:
                        c += f"{'exp ='.ljust(LJUST)} {ES}'b{get_bin(exp, ES, prefix=False)};\n"
                    ### mantissa
                    c += f"{'mant ='.ljust(LJUST)} {N}'b{get_bin(mant, N, prefix=False)};\n"
                c += f"{'is_zero ='.ljust(LJUST)} {p.is_zero.real};\n"
                c += f"{'is_nan ='.ljust(LJUST)} {p.is_nan.real};\n"
            c += f"#10;\n\n"

    elif args.operation == Tb.MUL:
        c = func(c, Tb.MUL, list_a, list_b)

    elif args.operation == Tb.ADD:
        c = func(c, Tb.ADD, list_a, list_b)

    elif args.operation == Tb.SUB:
        c = func(c, Tb.SUB, list_a, list_b)

    elif args.operation == Tb.DIV:
        c = func(c, Tb.DIV, list_a, list_b)

    elif args.operation == Tb.PPU:
        c = func(c, Tb.MUL, list_a, list_b)
        c = func(c, Tb.ADD, list_a, list_b)
        c = func(c, Tb.SUB, list_a, list_b)
        c = func(c, Tb.DIV, list_a, list_b)
        c = single_arg_func(c, Tb.FLOAT_TO_POSIT)
        c = single_arg_func(c, Tb.POSIT_TO_FLOAT) 

    elif args.operation == Tb.PACOGEN:
        c = func(c, Tb.PACOGEN, list_a, list_b)
    
    elif args.operation == Tb.FLOAT_TO_POSIT:
        c = single_arg_func(c, Tb.FLOAT_TO_POSIT)

    filename = pathlib.Path(f"../test_vectors/tv_posit_{args.operation}_P{N}E{ES}.sv")
    with open(filename, "w") as f:
        f.write(c)
        print(f"Wrote {filename.resolve()}")
