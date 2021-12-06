class Regime:
    (reg_s, reg_len) = (None, None)
    k = None

    def __init__(self, reg_s=None, reg_len=None, k=None):
        if ((reg_s, reg_len) == (None, None)) and (k != None):
            self._init_k(k)
        elif (reg_s != None and reg_len != None and bool(reg_s).real == reg_s) and (k == None):
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
        if self.k>=0:
            self.reg_s = 1
            self.reg_len = self.k+2
        else:
            self.reg_s = 0
            self.reg_len = -self.k+1

    def _calc_k(self):
        """Given leftmost regime bit (reg_s) and regime length (reg_len), computes k"""
        if self.reg_s == 1:
            self.k = self.reg_len-2
        else:
            self.k = -(self.reg_len-1)

    def get_bits(self, mask):
        return self.bits  # ~ (~1 << (self.reg_len - 2) << 1) & mask

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.__dict__ == other.__dict__
        else:
            return False
    
    def __repr__(self):
        return f"(reg_s, reg_len) = ({self.reg_s}, {self.reg_len}) -> k = {self.k}"
