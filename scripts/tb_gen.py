# pip install posit_playground

import random
from posit_playground import from_bits
from posit_playground.utils import get_bin

DECODE = 0
ENCODE = 1

NUM_RANDOM_TEST_CASES = 300

if __name__ == "__main__":
    N, ES = 8, 0

    list_a = random.sample(range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1))

    for a in list_a:
        p = from_bits(a, N, ES)

        if DECODE:
            # posit bits
            print(f"{'bits ='.ljust(25)} {N}'b{get_bin(p.bit_repr(), N)};")
            # sign
            print(f"{'sign_expected ='.ljust(25)} {p.sign};")
            # regime
            print(f"{'reg_s_expected ='.ljust(25)} {p.regime.reg_s};")
            print(f"{'reg_len_expected ='.ljust(25)} {p.regime.reg_len};")
            # print(f"{'k_expected ='.ljust(25)} {p.regime.k};")
            print(
                f"{'regime_bits_expected ='.ljust(25)} {N}'b{get_bin(p.regime.calc_reg_bits(), N) };"
            )
            # exponent
            print(f"{'exp_expected ='.ljust(25)} {N}'b{get_bin(p.exp, N)};")
            # mantissa
            print(f"{'mant_expected ='.ljust(25)} {N}'b{get_bin(p.mant, N)};")
        elif ENCODE:
            print(f"{'posit_expected ='.ljust(25)} {N}'b{get_bin(p.bit_repr(), N)};")
            ### sign
            print(f"{'sign ='.ljust(25)} {p.sign};")
            ### regime
            print(f"{'reg_s ='.ljust(25)} {p.regime.reg_s};")
            print(f"{'reg_len ='.ljust(25)} {p.regime.reg_len};")
            # print(f"{'k ='.ljust(25)} {p.regime.k};")
            print(
                f"{'regime_bits ='.ljust(25)} {N}'b{get_bin(p.regime.calc_reg_bits(), N) };"
            )
            ### exponent
            print(f"{'exp ='.ljust(25)} {N}'b{get_bin(p.exp, N)};")
            ### mantissa
            print(f"{'mant ='.ljust(25)} {N}'b{get_bin(p.mant, N)};")

        print(f"{'is_zero ='.ljust(25)} {p.is_zero.real};")
        print(f"{'is_inf ='.ljust(25)} {p.is_inf.real};")
        print(f"#10;\n")
