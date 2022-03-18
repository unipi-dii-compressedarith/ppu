import random
from posit_playground.posit import cls
from posit_playground.utils import get_bin

N = 32
NUM_TESTS = 200
TRUE_RANDOM = True

if not TRUE_RANDOM:
    random.seed(41)

for i in range(NUM_TESTS):
    # force 3 ones at random places in a N-sized string of bits.
    a, b, c = (
        int(random.randint(0, N - 1)),
        int(random.randint(0, N - 1)),
        int(random.randint(0, N - 1)),
    )
    bits = (1 << a) | (1 << b) | (1 << c)

    # force the string of bits to be all zero 15% of the time
    if random.random() < 0.15:
        bits = 0

    print(
        f"in_i = {N}'b{get_bin(bits, N, prefix=False)}; lz_expected = {cls(bits=bits, size=N, val=0)}; all_zeroes_expected = {(bits == 0).real}; #10; "
    )
