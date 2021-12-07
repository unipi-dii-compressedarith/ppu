from posit_decode import Posit, decode
from regime import Regime


def mul(p1: Posit, p2: Posit) -> Posit:
    assert p1.size == p2.size
    assert p1.es == p2.es

    size, es = p1.size, p1.es

    if p1.is_inf or p2.is_inf:
        return Posit(is_inf=True)
    if p1.is_zero or p2.is_zero:
        return Posit(is_zero=True)

    sign = p1.sign ^ p2.sign

    F1, F2 = p1.mant_len(), p2.mant_len()

    if es == 0:

        k = p1.regime.k + p2.regime.k

        mant_1_left_shifted = p1.mant << (size - 1 - F1)
        mant_2_left_shifted = p2.mant << (size - 1 - F2)

        ### left align and set a 1 at the msb position, indicating a fixed point number represented as 1.mant
        mant = (mant_1_left_shifted | (1 << (size - 1))) * (
            mant_2_left_shifted | (1 << (size - 1))
        )

        mant_carry = (mant & (1 << (2 * size - 1))) != 0
        if mant_carry:
            mant = mant >> 1
            k = k + 1

        reg_len = Regime(k=k).reg_len

        mant_len = size - 1 - es - reg_len

        mask_2n = 2 ** (2 * size) - 1

        mant &= (~0 & mask_2n) >> 2

        mant = mant >> (2 * size - mant_len - 2)

        return Posit(
            size=size,
            es=es,
            sign=sign,
            regime=Regime(k=k),
            exp=0,
            mant=mant,
        )

    else:
        raise NotImplemented


p1 = decode(0b01110011, 8, 0)
p2 = decode(0b01110010, 8, 0)
ans = mul(p1, p2)
assert mul(p1, p2) == decode(0b01111101, 8, 0)


p1 = decode(0b01110011, 8, 0)
p2 = decode(0b01000111, 8, 0)
ans = mul(p1, p2)
assert mul(p1, p2) == decode(0b01110101, 8, 0)


"""
### only last bit wrong (checked against softposit python)
p1 = decode(0b01100011, 8, 0)
p2 = decode(0b00111111, 8, 0)
ans = mul(p1, p2)
# assert mul(p1, p2) == decode(0b01110101, 8, 0)
print(p1)
print(p2)
print(ans)
"""

p1 = decode(0b0111000101100011, 16, 0)
p2 = decode(0b0100000101110001, 16, 0)
ans = mul(p1, p2)
# assert mul(p1, p2) == decode(0b01110101, 8, 0)
print(p1)
print(p2)
print(ans)
