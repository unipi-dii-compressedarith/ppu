"""
black posit_decode.py # code formatter (pip install black)
"""
import softposit as sp
from numpy import inf
import signal
import random
from math import ceil, log2

from regime import Regime
from posit import Posit, cls, c2


def handler(signum, frame):
    exit(1)


signal.signal(signal.SIGINT, handler)


get_bin = lambda x, n: format(x, "b").zfill(n)

def decode(bits, size=2, es=0) -> Posit:
    """
    Posit decoder.
    
    Break down P<size, es> in its components (sign, regime, exponent, mantissa).

    Prameters:
    bits (unsigned): sequence of bits representing the posit
    size (unsigned): length of posit
    es (unsigned): exponent field size.

    Returns:
    Posit object
    """
    size = max(size, ceil(log2(bits + 1)))

    mask = (2 ** size) - 1
    msb = 1 << (size - 1)
    sign = bits >> (size - 1)

    if (bits << 1) & mask == 0:
        return Posit(size, es, sign, Regime(k=-inf), 0, 0)


    u_bits = bits if sign == 0 else c2(bits, mask)
    reg_msb = 1 << (size - 2)
    reg_s = bool(u_bits & reg_msb)
    if reg_s == True:
        k = cls(u_bits << 1, size, 1) - 1
        reg_len = min(k + 2, size - 1)
    else:
        k = -cls(u_bits << 1, size, 0)
        reg_len = min(-k + 1, size - 1)

    regime_bits = ((u_bits << 1) & mask) >> (
        size - reg_len
    )

    # align remaining of u_bits to the left after dropping sign (1 bit) and regime (`reg_len` bits)
    exp = ((u_bits << (1 + reg_len)) & mask) >> max(0, (size - es))

    mant = ((u_bits << (1 + reg_len + es)) & mask) >> (1 + reg_len + es)

    return Posit(
        size=size,
        es=es,
        sign=sign,
        regime=Regime(k=k),
        exp=exp,
        mant=mant,
    )


assert decode(0b01110011, 8, 3) == Posit(
    size=8,
    es=3,
    sign=0,
    regime=Regime(k=2),
    exp=3,
    mant=0,
)

assert decode(0b01110111, 8, 2) == Posit(
    size=8,
    es=2,
    sign=0,
    regime=Regime(k=2),
    exp=3,
    mant=1,
)

assert decode(0b11110111, 8, 2) == Posit(
    size=8,
    es=2,
    sign=1,
    regime=Regime(k=-3),
    exp=0,
    mant=1,
)

assert decode(0b10110111, 8, 1) == Posit(
    size=8,
    es=1,
    sign=1,
    regime=Regime(reg_s=1, reg_len=2),
    exp=0,
    mant=0b1001,
)

assert decode(0b01111111, 8, 0) == Posit(
    size=8,
    es=0,
    sign=0,
    regime=Regime(
        k=6
    ),  # bug: regime=Regime(reg_s=1, reg_len=7), # bug: k does not account how long the size is when it returns reg_len regime=Regime(k=k),
    exp=0,
    mant=0b0,
)


if __name__ == "__main__":

    random.seed(10)

    NUM_RANDOM_TEST_CASES = 800

    N = 8
    list_of_bits = random.sample(range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1))
    for bits in list_of_bits:
        posit = decode(bits, 8, 0)
        assert posit.to_real() == sp.posit8(bits=bits)
        # print(f"bits = {N}'b{get_bin(bits, N)};")
        # print(posit.tb())

    """
    N, ES = 5, 1
    list_of_bits = random.sample(
        range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1)
    )
    for bits in list_of_bits:
        if bits != (1 << N - 1) and bits != 0:
            posit = decode(bits, N, ES)
            # posit.to_real()
            print(f"bits = {N}'b{get_bin(bits, N)};")
            print(posit.tb())
    """

    N = 16
    list_of_bits = random.sample(range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1))
    for bits in list_of_bits:
        assert decode(bits, 16, 1).to_real() == sp.posit16(bits=bits)

    """
    N = 32
    list_of_bits = random.sample(range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1))
    for bits in list_of_bits:
        print(get_bin(bits, N))
        if bits != (1 << N - 1) and bits != 0:
            assert decode(bits, 32, 2).to_real() == sp.posit32(bits=bits)

    print(decode(0b01110011, 8, 3))
    print(decode(0b11110011, 8, 0))
    print(decode(0b0110011101110011, 16, 1))
    """


    REPL = 1
    if REPL:
        while True:
            bits = input(">>> 0b") or "0"
            es = int(input(">>> es: ") or 0)
            print(decode(int(bits, 2), len(bits), es))

