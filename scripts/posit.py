import pytest
import softposit as sp
from numpy import inf

get_bin = lambda x, n: format(x, "b").zfill(n)
get_hex = lambda x, n: format(x, "x").zfill(n)

ANSI_COLOR_CYAN = "\x1b[36m"
ANSI_COLOR_GREY = "\x1b[90m"

RESET_COLOR = "\033[0m"
SIGN_COLOR = "\033[1;37;41m"
REG_COLOR = "\033[1;30;43m"
EXP_COLOR = "\033[1;37;44m"
MANT_COLOR = "\033[1;37;40m"


def shl(bits, rhs, size):
    """shift left on `size` bits"""
    mask = (2 ** size) - 1
    return (bits << rhs) & mask if rhs > 0 else bits


def shr(bits, rhs):
    """shift right"""
    return bits >> rhs if rhs > 0 else bits


def c2(bits, size):
    """two's complement on `size` bits"""
    mask = (2 ** size) - 1
    return (~bits & mask) + 1


def cls(bits, size, val=1):
    """count leading set
    counts leading `val`, leftwise
    """
    if val == 1:
        return _clo(bits, size)
    elif val == 0:
        return _clz(bits, size)
    else:
        raise ("val is binary! pass either 0 or 1.")


def _clo(bits, size):
    """count leading ones
    0b1111_0111 -> 4
    """
    mask = 2 ** size - 1
    bits &= mask
    if bool(bits & (1 << (size - 1))) == False:
        return 0
    return 1 + _clo(bits << 1, size)


def _clz(bits, size):
    """count leading zeros"""
    return _clo(~bits, size)


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

    @property
    def es_effective(self):
        """the actual size of the exponent field.
        This takes into account the cases such as
        P<16,0> 0b01111111_11111111 where the regime field overrides the exponent.
        This only comes into play when printed, it does not affect the `2 ** (2 ** es)` componenet.
        """
        return min(self.es, self.size - 1 - self.regime.reg_len)

    def mant_len(self):
        """length of mantissa field"""
        return max(0, self.size - 1 - self.regime.reg_len - self.es_effective)

    def bit_repr(self):
        """
        s_rrrr_e_mm =
        s_0000_0_00 |     sign
        0_rrrr_0_00 |     regime
        0_0000_e_00 |     exp
        0_0000_0_mm |     mant
        """
        if self.regime.reg_len == None:  # 0 or inf
            return 0 if self.sign == 0 else (1 << (self.size - 1))
        else:
            sign_shift = self.size - 1
            regime_shift = self.size - 1 - self.regime.reg_len
            exp_shift = self.size - 1 - self.regime.reg_len - self.es_effective

            regime_bits = self.regime.calc_reg_bits()

            bits = (
                shl(self.sign, sign_shift, self.size)
                | shl(regime_bits, regime_shift, self.size)
                | shl(self.exp, exp_shift, self.size)
                | self.mant
            )

            if self.sign == 0:
                return bits
            else:
                # ~(1 << (self.size - 1)) = 0x7f if 8 bits
                return c2(bits & ~(1 << (self.size - 1)), self.size)

    def to_real(self):
        if self.regime.reg_len == None:  # 0 or inf
            return 0 if self.sign == 0 else inf
        else:
            F = self.mant_len()
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
        if self.regime.reg_len == None:  # 0 or inf
            pass
        else:
            F = self.mant_len()
            if self.es == 0:
                return (
                    f"(-1)**{SIGN_COLOR}{self.sign.real}{RESET_COLOR} * "
                    + f"(2**{REG_COLOR}{self.regime.k}{RESET_COLOR}) * "
                    + f"(1 + {MANT_COLOR}{self.mant}{RESET_COLOR}/{2**F})"
                )
            else:
                return (
                    f"(-1)**{SIGN_COLOR}{self.sign.real}{RESET_COLOR} * "
                    + f"(2**(2**{EXP_COLOR}{self.es}{RESET_COLOR}))**{REG_COLOR}{self.regime.k}{RESET_COLOR} * "
                    + f"(2**{EXP_COLOR}{self.exp}{RESET_COLOR}) * "
                    + f"(1 + {MANT_COLOR}{self.mant}{RESET_COLOR}/{2**F})"
                )

    def tb(self):
        return f"""bits                 = {self.size}'b{get_bin(self.bit_repr(), self.size)};
sign = {self.sign.real};
reg_s = {self.regime.reg_s.real if self.regime.reg_s else ''};
reg_len = {self.regime.reg_len};
regime_bits_expected = {self.size}'b{get_bin(self.regime.calc_reg_bits(), self.size)};
exp_expected         = {self.size}'b{get_bin(self.exp, self.size)};
mant_expected        = {self.size}'b{get_bin(self.mant, self.size)};
#10;
"""

    def color_code(self):
        # bug with eg: bits = 0b0110 es 1
        """
        sign length:     1
        regime length:   self.regime.reg_len
        exponent length: es
        mantissa length: size - sign_len - reg_len - ex_len
        """
        mant_len = self.mant_len()
        regime_bits_str = f"{self.regime.calc_reg_bits():064b}"[
            64 - self.regime.reg_len :
        ]
        exp_bits_str = f"{self.exp:064b}"[
            64 - min(self.es_effective, self.size - 1 - self.regime.reg_len) :
        ]
        mant_bits_str = f"{self.mant:064b}"[64 - mant_len :]

        ans_no_color = f"{self.sign.real}{regime_bits_str}{exp_bits_str}{mant_bits_str}"

        ans = (
            f"{SIGN_COLOR}{self.sign.real}"
            + f"{REG_COLOR}{regime_bits_str}"
            + f"{EXP_COLOR}{exp_bits_str}"
            + f"{MANT_COLOR}{mant_bits_str}{RESET_COLOR}"
        )
        # assert len(ans_no_color) == self.size
        return ans

    def __repr__(self):
        regime_binary_repr = get_bin(self.regime.calc_reg_bits(), self.size)
        exponent_binary_repr = get_bin(self.exp, self.size)
        mantissa_binary_repr = get_bin(self.mant, self.size)

        ans = f"P<{self.size},{self.es}>: 0b{get_bin(self.bit_repr(), self.size)}\n"
        ans += f"{self.color_code()}\n"
        ans += f"{self.break_down()} = {self.to_real()}\n\n"
        ans += f"{'s:':<19}{SIGN_COLOR}{self.sign.real}{RESET_COLOR}\n"
        # ans += f"{'reg_s:':<19}{self.regime.reg_s.real}\n"
        # ans += f"{'reg_len:':<19}{self.regime.reg_len}\n"
        # ans += f"k: {self.regime.k}\n"
        ans += f"{self.regime}\n"
        ans += f"{'reg:':<19}{ANSI_COLOR_GREY}{regime_binary_repr[:self.size-self.regime.reg_len]}{REG_COLOR}{regime_binary_repr[self.size-self.regime.reg_len:]}{RESET_COLOR}\n"
        if self.es:
            ans += f"{'exp:':<19}{ANSI_COLOR_GREY}{exponent_binary_repr[:self.size-self.es_effective]}{EXP_COLOR}{exponent_binary_repr[self.size-self.es_effective:]}{RESET_COLOR}\n"
        ans += f"{'mant:':<19}{ANSI_COLOR_GREY}{mantissa_binary_repr[:self.size-self.mant_len()]}{MANT_COLOR}{mantissa_binary_repr[self.size-self.mant_len():]}{RESET_COLOR}\n"
        ans += f"F = mant_len: {self.mant_len()} -> 2**F = {2**self.mant_len()}\n"
        ans += f"{ANSI_COLOR_CYAN}{'~'*45}{RESET_COLOR}\n"
        return ans


if __name__ == "__main__":
    print(f"run `pytest posit.py -v` to run the tests.")


test_cls_inputs = [
    ((0b11111111, 8, 1), 8),
    ((0b11001100, 8, 1), 2),
    ((0b10111111, 8, 1), 1),
    ((0b11111110, 8, 1), 7),
    ((0b00111111, 8, 1), 0),
    ((0b01111111, 8, 0), 1),
    ((0b00001100, 8, 0), 4),
    ((0b00111111, 8, 0), 2),
]


@pytest.mark.parametrize("test_input,expected", test_cls_inputs)
def test_cls(test_input, expected):
    assert cls(*test_input) == expected
