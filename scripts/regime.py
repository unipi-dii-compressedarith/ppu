import pytest

ANSI_COLOR_GREY = "\x1b[90m"

RESET_COLOR = "\033[0m"
REG_COLOR = "\033[1;30;43m"

get_bin = lambda x, n: format(x, "b").zfill(n)


class Regime:
    def __init__(self, size, k=None):
        """k is None when the regime represents a 0 or infinity posit."""
        self.size = size
        if k == None or (k <= (size - 2) and k >= (-size + 1)):
            self.k = k
        else:
            raise Exception("k is out of bound")

    @property
    def reg_s(self):
        """
        'regime sign': leftmost regime bit
        (of the unsigned posit, i.e. two's complemented if negative"""
        if self.k == None:  # 0 or inf
            return None
        else:
            return bool(self.k >= 0).real

    @property
    def reg_len(self):
        """regime length, regardless of whether it's out of bound or not."""
        if self.k == None:  # 0 or inf
            return None
        elif self.k >= 0:
            return self.k + 2  # not bound checked
            # return min(self.size - 1, self.k + 2) # bound checked
        else:
            return -self.k + 1  # not bound checked
            # return min(self.size - 1, -self.k + 1) # bound checked

    @property
    def _reg_len_bound_checked(self):
        """regime length, used to represent the regime. It accounts for edge cases.
        e.g.:
        (reg_s, reg_len) = (1, 8) -> k = 6
        regime: 0_1111111
        """
        if self.k == None:  # 0 or inf
            return None
        return min(self.size - 1, self.reg_len) # bound checked
        
        
    def calc_reg_bits(self):
        if self.k == None:
            return 0
        elif self.k >= 0:
            if self.reg_len < self.size:
                return (2 ** (self.k + 1) - 1) << 1
            else:
                return 2 ** (self.k + 1) - 1
        else:
            if self.reg_len < self.size:
                return 1
            else:
                # when out of bounds, e.g.
                # >>> Regime(size=8, k=-7)
                # (reg_s, reg_len) = (0, 8) -> k = -7
                # regime: 00000000
                return 0
            mask = 2 ** self.size - 1
            return ~((2 ** (-self.k) - 1) << 1) & mask

    # def get_bits(self, size):
    #     mask = 2**size - 1
    #     return self.bits  # ~ (~1 << (self.reg_len - 2) << 1) & mask

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.__dict__ == other.__dict__
        else:
            return False

    def color_code(self):
        regime_bits_binary = get_bin(self.calc_reg_bits(), self.size)
        return f"{ANSI_COLOR_GREY}{regime_bits_binary[:self.size - self._reg_len_bound_checked]}{REG_COLOR}{regime_bits_binary[self.size-self._reg_len_bound_checked:]}{RESET_COLOR}"

    def __repr__(self):
        return f"{self.color_code()} -> " + f"(reg_s, reg_len) = ({self.reg_s}, {self.reg_len}) -> k = {self.k}"


if __name__ == "__main__":
    print(f"run `pytest regime.py -v` to run the tests.")


tb = [
    (Regime(size=8, k=1).calc_reg_bits(), 0b00000110),
    (Regime(size=8, k=2).calc_reg_bits(), 0b00001110),
    (Regime(size=8, k=0).calc_reg_bits(), 0b00000010),
    (Regime(size=8, k=-3).calc_reg_bits(), 0b00000001),
    (Regime(size=8).calc_reg_bits(), 0b00000000),
    (
        Regime(size=16, k=14).calc_reg_bits(),
        0b0111111111111111,
    ),  # technically true but it needs to be >> 1 later on because it doesn't fit.
    (Regime(size=16, k=13).calc_reg_bits(), 0b111111111111110),
]


@pytest.mark.parametrize("left,right", tb)
def test_regime(left, right):
    assert left == right
