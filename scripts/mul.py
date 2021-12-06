from posit_decode import Posit, Regime


def build_reg_bits(k, size):
    if k >= 0:
        return (2**(k+1) - 1) << 1
    else:
        mask = 2**size -1
        return ~( (2**(-k) - 1) << 1 ) & mask

def mul(p1: Posit, p2: Posit) -> Posit:
    assert p1.size == p2.size
    assert p1.es == p2.es

    size, es = p1.size, p1.es

    if p1.is_zero or p2.is_zero:
        return Posit(is_zero=True)
    if p1.is_inf or p2.is_inf:
        return Posit(is_inf=True)
    
    if es == 0:

        k = p1.regime.k + p2.regime.k

        mant = p1.mant * p2.mant
        
        mant_carry = (mant & (1 << (2*size - 1))) != 0
        if mant_carry:
            mant = mant >> 1
            k = k + 1
        
        regime = build_reg_bits(k)
    
        return Posit(
            size=size, 
            es=es, 
            sign=p1.sign ^ p2.sign,
            regime=Regime(bits=regime_bits, reg_s=reg_s, reg_len=reg_len, k=k),
            exp=0,
            mant=mant)

    else:
        raise NotImplemented

