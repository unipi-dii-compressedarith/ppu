class Regime:
    (reg_s, reg_len) = (None, None)
    k = None

    def __init__(self, reg_s=None, reg_len=None, k=None):
        if ((reg_s, reg_len) == (None, None)) and (k != None):
            self._init_k(k)
        elif (reg_s != None and reg_len != None) and (k == None):
            if bool(reg_s).real != reg_s:
                print("reg_s has to be either 0 or 1.")
            elif reg_len <= 1:
                print(
                    "`reg_len` has to be > 0. It can be 1 but it's an edge case not yet handled."
                )
            else:
                self._init_reg_s_reg_len(reg_s, reg_len)
        else:
            print("cant initialize regime")

    def _init_k(self, k):
        if (self.reg_s, self.reg_len) == (None, None):
            self.k = k
            self._calc_reg_s_reg_len()

    def _init_reg_s_reg_len(self, reg_s, reg_len):
        if self.k == None:
            self.reg_s = reg_s
            self.reg_len = reg_len
            self._calc_k()

    def _calc_reg_s_reg_len(self):
        """Given k, computes leftmost regime bit (reg_s) and regime length (reg_len)"""
        if self.k >= 0:
            self.reg_s = 1
            self.reg_len = self.k + 2
        else:
            self.reg_s = 0
            self.reg_len = -self.k + 1

    def _calc_k(self):
        """Given leftmost regime bit (reg_s) and regime length (reg_len), computes k"""
        if self.reg_s == 1:
            self.k = self.reg_len - 2
        else:
            self.k = -(self.reg_len - 1)

    def calc_reg_bits(self, size=64):
        if self.k >= 0:
            return (2 ** (self.k + 1) - 1) << 1
        else:
            return 1
            mask = 2 ** size - 1
            return ~((2 ** (-self.k) - 1) << 1) & mask

    # def get_bits(self, size):
    #     mask = 2**size - 1
    #     return self.bits  # ~ (~1 << (self.reg_len - 2) << 1) & mask

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.__dict__ == other.__dict__
        else:
            return False

    def __repr__(self):
        return f"(reg_s, reg_len) = ({self.reg_s}, {self.reg_len}) -> k = {self.k}"


if __name__ == "__main__":
    assert Regime(k=1).calc_reg_bits(size=8) == 0b00000110
    assert Regime(k=2).calc_reg_bits(size=8) == 0b00001110
    assert Regime(k=0).calc_reg_bits(size=8) == 0b00000010
    assert Regime(k=-3).calc_reg_bits(size=8) == 0b00000001
    assert Regime(reg_s=1, reg_len=4).calc_reg_bits() == 0b00001110
