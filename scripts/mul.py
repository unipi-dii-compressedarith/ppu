from posit_decode import decode
from posit import Posit, get_bin
from regime import Regime

import pytest
import os


RESET_COLOR = "\033[0m"
SIGN_COLOR = "\033[1;37;41m"
REG_COLOR = "\033[1;30;43m"
EXP_COLOR = "\033[1;37;44m"
MANT_COLOR = "\033[1;37;40m"


def shl(bits, rhs, size):
    mask = (2 ** size) - 1
    return (bits << rhs) & mask if rhs > 0 else bits


msb = lambda N: shl(1, N - 1, N)  # 8bits: 1 << 8 i.e. 1000_0000
mask = lambda N: 2 ** N - 1  # 8bits: 1111_1111


def mul(p1: Posit, p2: Posit) -> Posit:
    assert p1.size == p2.size
    assert p1.es == p2.es

    size, es = p1.size, p1.es
    sign = p1.sign ^ p2.sign

    if p1.bit_repr() == msb(size) or p2.bit_repr() == msb(size):
        return Posit(size, es, sign, Regime(), 0, 0)
    if p1.bit_repr() == 0 or p2.bit_repr() == 0:
        return Posit(size, es, sign, Regime(), 0, 0)

    F1, F2 = p1.mant_len(), p2.mant_len()

    k = p1.regime.k + p2.regime.k
    exp = p1.exp + p2.exp

    mant_1_left_aligned = p1.mant << (size - 1 - F1)
    mant_2_left_aligned = p2.mant << (size - 1 - F2)

    ### left align and set a 1 at the msb position, indicating a fixed point number represented as 1.mant
    f1 = mant_1_left_aligned | msb(size)
    f2 = mant_2_left_aligned | msb(size)
    mant = f1 * f2  # fixed point mantissa product of 1.fff.. * 1.ffff.. on 2N bits

    print(
        f"""{' '*size}{MANT_COLOR}{get_bin(f1, size)[:1]}{RESET_COLOR}{get_bin(f1, size)[1:]} x
{' '*size}{MANT_COLOR}{get_bin(f2, size)[:1]}{RESET_COLOR}{get_bin(f2, size)[1:]} =
{'-'*(2*size + 2)}
{MANT_COLOR}{get_bin(mant, 2*size)[:2]}{RESET_COLOR}{get_bin(mant, 2*size)[2:]}
"""
    )

    mant_carry = bool((mant & msb(2 * size)) != 0).real
    print(f"mant_carry = {MANT_COLOR}{mant_carry.real}{RESET_COLOR}")
    print(
        f"k + exp + mant_carry = {REG_COLOR}{k}{RESET_COLOR} + {EXP_COLOR}{exp}{RESET_COLOR} + {MANT_COLOR}{mant_carry}{RESET_COLOR}"
    )

    if mant_carry == 1:
        exp += 1
        mant_carry -= 1
        mant = mant >> 1

    exp_carry = bool((exp & msb(es)) != 0).real
    if exp_carry == 1:
        k += 1
        exp_carry -= 1
        exp >>= 1

    # k += int(exp / (2**es))
    # exp = exp % (2**es)

    #### fix overflow / underflow of k

    print(f"k + exp + mant_carry = {k} + {exp} + {mant_carry}")

    reg_len = Regime(k=k).reg_len

    mant_len = size - 1 - es - reg_len

    mant &= (~0 & mask(2 * size)) >> 2

    mant = mant >> (2 * size - mant_len - 2)

    return Posit(
        size=size,
        es=es,
        sign=sign,
        regime=Regime(k=k),
        exp=0,
        mant=mant,
    )


if __name__ == "__main__":

    p1 = decode(0b01100011, 8, 0)
    p2 = decode(0b00111111, 8, 0)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    # assert mul(p1, p2) == decode(0b01110101, 8, 0)  ### only last bit wrong (checked against softposit python)
    print(ans)

    p1 = decode(0b0111000101100011, 16, 0)
    p2 = decode(0b0100000101110001, 16, 0)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b100110, 6, 0)
    p2 = decode(0b110010, 6, 0)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b01100011111011001, 17, 0)
    p2 = decode(0b11111100010100011, 17, 0)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b011111011100011111011001, 24, 0)
    p2 = decode(0b111111100011100010100011, 24, 0)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b001011, 6, 1)
    p2 = decode(0b100111, 6, 1)
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b01110000011100001010001111010111, 32, 2)  # 312.3199996948242
    p2 = decode(0b00101100110011001100110011001101, 32, 2)  # 0.20000000018626451
    print(p1)
    print(p2)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b0011101000111100, 16, 1)  # 0.81982421875
    p2 = decode(0b0011000011100111, 16, 1)  # 0.5281982421875
    print(p1)
    print(p2)
    # assert mul(p1, p2) == decode(0b0010101110110111, 16, 1)
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b00110001, 8, 0)  # 0.765625
    p2 = decode(0b01100010, 8, 0)  # 2.25
    print(p1)
    print(p2)
    # assert mul(p1, p2) == decode(0b01100010, 8, 0)  # 1.71875    # last bit fails
    ans = mul(p1, p2)
    print(ans)

    p1 = decode(0b10110001, 8, 0)  # -1.46875
    p2 = decode(0b01101010, 8, 0)  # 3.25
    print(p1)
    print(p2)
    # assert mul(p1, p2) == decode(0b10001110, 8, 0) # -5.0
    ans = mul(p1, p2)  #              10001111
    print(ans)

    os.system("clear")
    p1 = decode(0b1001001100001100, 16, 1)  # 0x930c   # -12.953125
    p2 = decode(0b0101010101010010, 16, 1)  # 0x5552   # 2.6650390625
    print(p1)
    print(p2)
    # assert mul(p1, p2) == decode(0b1000101110101111, 16, 1)
    ans = mul(p1, p2)
    print(ans)


# todo: figure out why it doesnt work (try paper version first)


if __name__ == "__main__":
    print(f"run `pytest mul.py -v` to run the tests.")


test_mul_inputs = [
    ((decode(0b01110011, 8, 0), decode(0b01110010, 8, 0)), decode(0b01111101, 8, 0)),
    ((decode(0b01110011, 8, 0), decode(0b01000111, 8, 0)), decode(0b01110101, 8, 0)),
    # (
    #     (Posit(16,1,0,Regime(k=3),0,2), Posit(16,1,0,Regime(k=2),0,3)),
    #     Posit(16,1,1,Regime(k=2),1,0b1010000)
    # ),
    ((decode(0b00000001, 8, 0), decode(0b01111111, 8, 0)), decode(0b01000000, 8, 0)),
]


@pytest.mark.parametrize("test_input,expected", test_mul_inputs)
def test_cls(test_input, expected):
    assert mul(*test_input) == expected
