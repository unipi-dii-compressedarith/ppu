# import softposit as sp  # used for printing only

import signal


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
    def __init__(self, size, es, sign, regime, exp, mant):
        self.size = size
        self.es = es
        self.sign = sign
        self.regime = regime
        self.exp = exp or 0
        self.mant = mant

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
        return (
            shl(self.sign, (self.size - 1), self.size)
            + shl(self.regime.bits, (self.size - 1 - self.regime.reg_len), self.size)
            + shl(self.exp, (self.size - 1 - self.regime.reg_len - self.es), self.size)
            + self.mant
        )

    def color_code(self):
        # bug with eg: bits = 0b0110 es 1
        """
        sign_len = 1
        reg_len = self.regime.reg_len
        ex_len = es
        mant_len = size - sign_len - reg_len - ex_len
        """
        mant_len = self.size - 1 - self.regime.reg_len - self.es
        regime_bits_str = f"{self.regime.bits:032b}"[32 - self.regime.reg_len :]
        exp_bits_str = f"{self.exp:032b}"[32 - self.es :]
        mant_bits_str = f"{self.mant:032b}"[32 - mant_len :]
        # breakpoint()
        return f"{SIGN_COLOR}{self.sign.real}{REG_COLOR}{regime_bits_str}{EXP_COLOR}{exp_bits_str}{MANT_COLOR}{mant_bits_str}{RESET_COLOR}"

    def __repr__(self):
        return f"""P<{self.size},{self.es}>: {self.color_code()} {get_bin(self.bit_repr(), self.size)}
s:    {self.sign.real}
reg_s:{self.regime.reg_s.real}
reg_len:{self.regime.reg_len}
reg:  {get_bin(self.regime.bits, self.size)}
k:    {self.regime.k}
{f'exp:  {get_bin(self.exp, self.size)}' if self.es else ''}
mant: {get_bin(self.mant, self.size)}
{'-'*20}"""


def c2(bits, mask):
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

    MASK = (2 ** size) - 1
    msb = 1 << (size - 1)
    sign = bool(bits & msb)
    u_bits = bits if sign == 0 else c2(bits, MASK)
    reg_msb = 1 << (size - 2)
    reg_s = bool(u_bits & reg_msb)
    if reg_s == True:
        k = clo(u_bits << 1, size) - 1
        reg_len = min(k + 2, size - 1)
    else:
        k = -clz(u_bits << 1, size)
        reg_len = min(-k + 1, size - 1)

    regime_bits = ((u_bits << 1) & MASK) >> (
        size - reg_len
    )  # Regime(reg_s, reg_len, k).get_bits(MASK)

    # align remaining of u_bits to the left after dropping sign (1 bit) and regime (`reg_len` bits)
    exp = ((u_bits << (1 + reg_len)) & MASK) >> (size - es)

    mant = ((u_bits << (1 + reg_len + es)) & MASK) >> (1 + reg_len + es)

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
assert clz(0b00001110, 8) == 4
assert clz(0b00000000, 8) == 8


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

# print(decode(0b01110011, 8, 3))
# print(decode(0b11110011, 8, 0))
# print(decode(0b0110011101110011, 16, 1))

while True:
    bits = input(">>> 0b") or "0"
    es = int(input(">>> es: ") or 0)
    print(decode(int(bits, 2), len(bits), es))
