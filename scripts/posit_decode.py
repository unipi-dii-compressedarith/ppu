import softposit as sp  # used for printing only

RESET_COLOR = "\033[0m"
SIGN_COLOR = "\033[1;37;41m"
REG_COLOR = "\033[1;30;43m"
EXP_COLOR = "\033[1;37;44m"
MANT_COLOR = "\033[1;37;40m"


def shl(bits, rhs, mask):
    return (bits << rhs) & mask if rhs > 0 else bits


def shr(bits, rhs):
    return bits >> rhs if rhs > 0 else bits


class Regime:
    def __init__(self, bits, reg_s, reg_len, k):
        self.bits = bits
        self.reg_s = reg_s
        self.reg_len = reg_len
        self.k = k

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
        s_0000_0_00 +     # sign
        0_rrrr_0_00 +     # regime
        0_0000_e_00 +     # exp
        0_0000_0_mm +     # mant
        #"""
        return (
            (self.sign << (self.size - 1))
            + (self.regime.bits << (self.size - 1 - self.regime.reg_len))
            + (self.exp << (self.size - 1 - self.regime.reg_len - self.es))
            + self.mant
        )

    def print_colored(self):
        regime_bits_str = f"{self.regime.bits:032b}"[32 - self.regime.reg_len :]
        exp_bits_str = f"{self.exp:032b}"[32 - self.es + 1 :]
        mant_bits_str = f"{self.mant:032b}"[32 - self.mant :]
        # breakpoint()
        return f"{SIGN_COLOR}{self.sign.real}{REG_COLOR}{regime_bits_str}{EXP_COLOR}{exp_bits_str}{MANT_COLOR}{mant_bits_str}{RESET_COLOR}"

    def __repr__(self):
        colored_repr = sp.convertToColor(self.bit_repr(), self.size, self.es)

        if self.size == 8:
            return f"""{colored_repr}
s:    {self.sign.real}
reg:  {self.regime.bits:08b}
k:    {self.regime.k}
{f'exp:  {self.exp:08b}' if self.es else ''}
mant: {self.mant:08b}"""
        if self.size == 16:
            return f"""{colored_repr}
s:    {self.sign.real}
reg:  {self.regime.bits:016b}
k:    {self.regime.k}
{f'exp:  {self.exp:016b}' if self.es else ''}
mant: {self.mant:016b}"""


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
        reg_len = k + 2
    else:
        k = -clz(u_bits << 1, size)
        reg_len = -k + 1

    regime = ((u_bits << 1) & MASK) >> (size - reg_len)

    # align remaining of u_bits to the left after dropping sign (1 bit) and regime (`reg_len` bits)
    exp = ((u_bits << (1 + reg_len)) & MASK) >> (size - es)

    mant = ((u_bits << (1 + reg_len + es)) & MASK) >> (1 + reg_len + es)

    return Posit(
        size=size,
        es=es,
        sign=sign,
        regime=Regime(bits=regime, reg_s=reg_s, reg_len=reg_len, k=k),
        exp=exp,
        mant=mant,
    )


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

# assert decode(0b11110011, 8, 0) == Posit(
#     size=8, es=0, sign=1, regime=Regime(bits=0b1, reg_s=1, reg_len=4, k=-3), exp=0, mant=0b101
# )

print(decode(0b01110011, 8, 3))
print(decode(0b11110011, 8, 0))
print(decode(0b0110011101110011, 16, 1))
