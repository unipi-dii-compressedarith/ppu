"""
black posit_decode.py # code formatter (pip install black)
"""
import softposit as sp
from numpy import inf
import signal
import random


def handler(signum, frame):
    exit(1)


signal.signal(signal.SIGINT, handler)


RESET_COLOR = "\033[0m"
SIGN_COLOR = "\033[1;37;41m"
REG_COLOR = "\033[1;30;43m"
EXP_COLOR = "\033[1;37;44m"
MANT_COLOR = "\033[1;37;40m"

get_bin = lambda x, n: format(x, "b").zfill(n)
get_hex = lambda x, n: format(x, "h").zfill(n)


def shl(bits, rhs, size):
    mask = (2 ** size) - 1
    return (bits << rhs) & mask if rhs > 0 else bits


def shr(bits, rhs):
    return bits >> rhs if rhs > 0 else bits


class Regime:
    def __init__(self, bits, reg_s, reg_len, k):
        self.bits = bits
        self.reg_s = reg_s
        self.reg_len = reg_len
        self.k = k

    def get_bits(self, mask):
        return self.bits  # ~ (~1 << (self.reg_len - 2) << 1) & mask

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.__dict__ == other.__dict__
        else:
            return False


class Posit:
    def __init__(self, size, es, sign, regime, exp, mant, is_zero=False, is_inf=False):
        self.size = size
        self.es = es
        self.sign = sign
        self.regime = regime
        self.exp = exp or 0
        self.mant = mant
        self.is_zero = is_zero
        self.is_inf = is_inf

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.__dict__ == other.__dict__
        else:
            return False

    def bit_repr(self):
        """
        s_rrrr_e_mm =
        s_0000_0_00 +     sign
        0_rrrr_0_00 +     regime
        0_0000_e_00 +     exp
        0_0000_0_mm +     mant
        """
        bits = (
            shl(self.sign, (self.size - 1), self.size)
            + shl(self.regime.bits, (self.size - 1 - self.regime.reg_len), self.size)
            + shl(self.exp, (self.size - 1 - self.regime.reg_len - self.es), self.size)
            + self.mant
        )
        if self.sign == 0:
            return bits
        else:
            # ~(1 << (self.size - 1)) = 0x7f if 8 bits
            return c2(bits & ~(1 << (self.size - 1)), self.size)

    def to_real(self):
        if self.is_zero:
            return 0
        elif self.is_inf:
            return inf  # numpy.inf
        else:
            F = self.size - 1 - self.regime.reg_len - self.es  # length of mantissa
            try:
                return (
                    (-1) ** self.sign.real
                    * (2 ** (2 ** self.es)) ** self.regime.k
                    * (2 ** self.exp)
                    * (1 + self.mant / (2 ** F))
                )
            except OverflowError:
                return inf

    def break_down(self):
        if self.is_zero:
            return 0
        elif self.is_inf:
            return inf  # numpy.inf
        else:
            F = self.mant_len()
            return f"(-1)**{SIGN_COLOR}{self.sign.real}{RESET_COLOR} * (2**(2**{EXP_COLOR}{self.es}{RESET_COLOR}))**{REG_COLOR}{self.regime.k}{RESET_COLOR} * (2 ** {EXP_COLOR}{self.exp}{RESET_COLOR}) * (1 + {MANT_COLOR}{self.mant}{RESET_COLOR}/{2**F})"

    def tb(self):
        return f"""bits                 = {self.size}'b{get_bin(self.bit_repr(), self.size)};
sign = {self.sign.real};
reg_s = {self.regime.reg_s.real};
reg_len = {self.regime.reg_len};
regime_bits_expected = {self.size}'b{get_bin(self.regime.bits, self.size)};
exp_expected         = {self.size}'b{get_bin(self.exp, self.size)};
mant_expected        = {self.size}'b{get_bin(self.mant, self.size)};
#10;
"""

    def mant_len(self):
        return self.size - 1 - self.regime.reg_len - self.es

    def color_code(self):
        # bug with eg: bits = 0b0110 es 1
        """
        sign length:     1
        regime length:   self.regime.reg_len
        exponent length: es
        mantissa length: size - sign_len - reg_len - ex_len
        """
        mant_len = self.mant_len()
        regime_bits_str = f"{self.regime.bits:064b}"[64 - self.regime.reg_len :]
        exp_bits_str = f"{self.exp:064b}"[64 - self.es :]
        mant_bits_str = f"{self.mant:064b}"[64 - mant_len :]

        ans_no_color = f"{self.sign.real}{regime_bits_str}{exp_bits_str}{mant_bits_str}"

        ans = f"{SIGN_COLOR}{self.sign.real}{REG_COLOR}{regime_bits_str}{EXP_COLOR}{exp_bits_str}{MANT_COLOR}{mant_bits_str}{RESET_COLOR}"
        # assert len(ans_no_color) == self.size
        return ans

    def __repr__(self):
        return f"""P<{self.size},{self.es}>: {self.color_code()} 
{get_bin(self.bit_repr(), self.size)} 
{self.break_down()} = {self.to_real()} 
s:    {self.sign.real}
reg_s:{self.regime.reg_s.real}
reg_len:{self.regime.reg_len}
reg:  {get_bin(self.regime.bits, self.size)}
k:    {self.regime.k}
{f'exp:  {get_bin(self.exp, self.size)}' if self.es else ''}
mant_len: {self.mant_len()} -> 2**F = {2**self.mant_len()}
mant: {get_bin(self.mant, self.size)}
{'-'*20}"""


def c2(bits, size):
    mask = (2 ** size) - 1
    return (~bits & mask) + 1


def clo(bits, size):
    """count leading ones
    0b1111_0111 -> 4
    """
    if bool(bits & (1 << (size - 1))) == False:
        return 0
    return 1 + clo(bits << 1, size)


def clz(bits, size):
    """count leading zeros"""
    return clo(~bits, size)


def decode(bits, size, es) -> Posit:
    """Break down P<size, es> in its components (sign, regime, exponent, mantissa)"""
    mask = (2 ** size) - 1
    msb = 1 << (size - 1)
    sign = bits >> (size - 1)
    if (bits << 1) & mask == 0:
        if sign == 0:
            return Posit(is_zero=True)  # to be fixed
        else:
            return Posit(is_inf=True)  # to be fixed
    u_bits = bits if sign == 0 else c2(bits, mask)
    reg_msb = 1 << (size - 2)
    reg_s = bool(u_bits & reg_msb)
    if reg_s == True:
        k = clo(u_bits << 1, size) - 1
        reg_len = min(k + 2, size - 1)
    else:
        k = -clz(u_bits << 1, size)
        reg_len = min(-k + 1, size - 1)

    regime_bits = ((u_bits << 1) & mask) >> (
        size - reg_len
    )  # Regime(reg_s, reg_len, k).get_bits(mask)

    # align remaining of u_bits to the left after dropping sign (1 bit) and regime (`reg_len` bits)
    exp = ((u_bits << (1 + reg_len)) & mask) >> max(0, (size - es))

    mant = ((u_bits << (1 + reg_len + es)) & mask) >> (1 + reg_len + es)

    return Posit(
        size=size,
        es=es,
        sign=sign,
        regime=Regime(regime_bits, reg_s, reg_len, k),
        exp=exp,
        mant=mant,
    )


assert clo(0b01111111 << 1, 8) == 7
assert clo(0b11111111, 8) == 8
assert clo(0b11001100, 8) == 2
assert clo(0b10111111, 8) == 1
assert clo(0b11111110, 8) == 7
assert clo(0b00111111, 8) == 0

assert clz(0b01111111, 8) == 1
assert clz(0b00001100, 8) == 4
assert clz(0b00111111, 8) == 2


assert decode(0b01110011, 8, 3) == Posit(
    size=8,
    es=3,
    sign=0,
    regime=Regime(bits=0b1110, reg_s=1, reg_len=4, k=2),
    exp=3,
    mant=0,
)

assert decode(0b01110111, 8, 2) == Posit(
    size=8,
    es=2,
    sign=0,
    regime=Regime(bits=0b1110, reg_s=1, reg_len=4, k=2),
    exp=3,
    mant=1,
)

assert decode(0b11110111, 8, 2) == Posit(
    size=8,
    es=2,
    sign=1,
    regime=Regime(bits=0b001, reg_s=0, reg_len=4, k=-3),
    exp=0,
    mant=1,
)

assert decode(0b10110111, 8, 1) == Posit(
    size=8,
    es=1,
    sign=1,
    regime=Regime(bits=0b10, reg_s=1, reg_len=2, k=0),
    exp=0,
    mant=0b1001,
)

assert decode(0b01111111, 8, 0) == Posit(
    size=8,
    es=0,
    sign=0,
    regime=Regime(bits=0b01111111, reg_s=1, reg_len=7, k=6),
    exp=0,
    mant=0b0,
)

if __name__ == "__main__":

    random.seed(10)

    NUM_RANDOM_TEST_CASES = 80

    N = 8
    list_of_bits = random.sample(range(0, 2 ** N - 1), NUM_RANDOM_TEST_CASES)
    for bits in list_of_bits:
        if bits != (1 << N - 1) and bits != 0:
            posit = decode(bits, 8, 0)
            assert posit.to_real() == sp.posit8(bits=bits)
            # print(f"bits = {N}'b{get_bin(bits, N)};")
            print(posit.tb())

    # N, ES = 5, 1
    # list_of_bits = random.sample(
    #     range(0, 2 ** N - 1), min(NUM_RANDOM_TEST_CASES, 2 ** N - 1)
    # )
    # for bits in list_of_bits:
    #     if bits != (1 << N - 1) and bits != 0:
    #         posit = decode(bits, N, ES)
    #         # posit.to_real()
    #         print(f"bits = {N}'b{get_bin(bits, N)};")
    #         print(posit.tb())

    # N = 16
    # list_of_bits = random.sample(range(0, 2 ** N - 1), NUM_RANDOM_TEST_CASES)
    # for bits in list_of_bits:
    #     print(get_bin(bits, N))
    #     if bits != (1 << N - 1) and bits != 0:
    #         assert decode(bits, 16, 1).to_real() == sp.posit16(bits=bits)

    # N = 32
    # list_of_bits = random.sample(range(0, 2 ** N - 1), NUM_RANDOM_TEST_CASES)
    # for bits in list_of_bits:
    #     print(get_bin(bits, N))
    #     if bits != (1 << N - 1) and bits != 0:
    #         assert decode(bits, 32, 2).to_real() == sp.posit32(bits=bits)

    # print(decode(0b01110011, 8, 3))
    # print(decode(0b11110011, 8, 0))
    # print(decode(0b0110011101110011, 16, 1))

    REPL = 1
    if REPL:
        while True:
            bits = input(">>> 0b") or "0"
            es = int(input(">>> es: ") or 0)
            print(decode(int(bits, 2), len(bits), es))
