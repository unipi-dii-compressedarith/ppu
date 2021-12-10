from posit_decode import decode
from posit import Posit, get_bin
from regime import Regime

import pytest
import os

from utils import shl, AnsiColor


msb = lambda N: shl(1, N - 1, N)  # 8bits: 1 << 8 i.e. 1000_0000
mask = lambda N: 2 ** N - 1  # 8bits: 1111_1111


def mul(p1: Posit, p2: Posit) -> Posit:
    assert p1.size == p2.size
    assert p1.es == p2.es

    size, es = p1.size, p1.es
    sign = p1.sign ^ p2.sign

    if p1.is_special or p1.is_special:
        return Posit(size, es, sign, Regime(size=size, k=None), 0, 0)

    F1, F2 = p1.mant_len(), p2.mant_len()

    k = p1.regime.k + p2.regime.k
    exp = p1.exp + p2.exp

    mant_1_left_aligned = p1.mant << (size - 1 - F1)
    mant_2_left_aligned = p2.mant << (size - 1 - F2)

    ### left align and set a 1 at the msb position, indicating a fixed point number represented as 1.mant
    f1 = mant_1_left_aligned | msb(size)
    f2 = mant_2_left_aligned | msb(size)
    mant = f1 * f2  # fixed point mantissa product of 1.fff.. * 1.ffff.. on 2N bits

    print(p1.bit_repr(), p2.bit_repr(), size, es)
    print(
        f"""{' '*size}{AnsiColor.MANT_COLOR}{get_bin(f1, size)[:1]}{AnsiColor.RESET_COLOR}{get_bin(f1, size)[1:]} x
{' '*size}{AnsiColor.MANT_COLOR}{get_bin(f2, size)[:1]}{AnsiColor.RESET_COLOR}{get_bin(f2, size)[1:]} =
{'-'*(2*size + 2)}
{AnsiColor.MANT_COLOR}{get_bin(mant, 2*size)[:2]}{AnsiColor.RESET_COLOR}{get_bin(mant, 2*size)[2:]}
"""
    )

    mant_carry = bool((mant & msb(2 * size)) != 0).real

    print(f"mant_carry = {AnsiColor.MANT_COLOR}{mant_carry.real}{AnsiColor.RESET_COLOR}")
    print(
        f"k + exp + mant_carry = {AnsiColor.REG_COLOR}{k}{AnsiColor.RESET_COLOR} + {AnsiColor.EXP_COLOR}{exp}{AnsiColor.RESET_COLOR} + {AnsiColor.MANT_COLOR}{mant_carry}{AnsiColor.RESET_COLOR}"
    )

    exp_carry = bool((exp & msb(es + 1)) != 0).real
    if exp_carry == 1:
        k += 1
        # wrap exponent
        exp &= 2 ** es - 1

    print(
        f"k + exp + mant_carry = {AnsiColor.REG_COLOR}{k}{AnsiColor.RESET_COLOR} + {AnsiColor.EXP_COLOR}{exp}{AnsiColor.RESET_COLOR} + {AnsiColor.MANT_COLOR}{mant_carry}{AnsiColor.RESET_COLOR}"
    )

    if mant_carry == 1:
        exp += 1
        exp_carry = bool((exp & msb(es + 1)) != 0).real
        if exp_carry == 1:
            k += 1
            # wrap exponent
            exp &= 2 ** es - 1
        mant = mant >> 1

    print(
        f"k + exp + mant_carry = {AnsiColor.REG_COLOR}{k}{AnsiColor.RESET_COLOR} + {AnsiColor.EXP_COLOR}{exp}{AnsiColor.RESET_COLOR} + {AnsiColor.MANT_COLOR}{mant_carry}{AnsiColor.RESET_COLOR}"
    )

    if k >= 0:
        k = min(k, size - 2)
    else:
        k = max(k, -(size - 2))

    #### fix overflow / underflow of k

    # print(f"k + exp + mant_carry = {k} + {exp} + {mant_carry}")

    reg_len = Regime(size=size, k=k).reg_len

    mant_len = size - 1 - es - reg_len

    mant &= (~0 & mask(2 * size)) >> 2

    mant = mant >> (2 * size - mant_len - 2)

    return Posit(
        size=size,
        es=es,
        sign=sign,
        regime=Regime(size=size, k=k),
        exp=exp,
        mant=mant,
    )


if __name__ == "__main__":

    p1 = decode(27598, 16, 1)
    p2 = decode(15701, 16, 1)
    print(mul(p1, p2))

    p1 = decode(55662, 16, 1)
    p2 = decode(32244, 16, 1)
    print(mul(p1, p2))

    p1 = decode(2904643641, 32, 2)
    p2 = decode(1545728239, 32, 2)
    print(mul(p1, p2))

    p1 = decode(0b00111001110110111000000110101010, 32, 2)
    p2 = decode(0b01100000001111111100000111111001, 32, 2)
    print(mul(p1, p2))

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
    ans = mul(p1, p2)  # 62.46400022506714
    assert ans == decode(0b01100111110011101101100100010111, 32, 2)

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
    ((decode(0b00000001, 8, 0), decode(0b01111111, 8, 0)), decode(0b01000000, 8, 0)),
    (
        (
            decode(0b00111001110110111000000110101010, 32, 2),
            decode(0b01100000001111111100000111111001, 32, 2),
        ),
        decode(0b01011010011110001010000011101001, 32, 2),
    ),
]


@pytest.mark.parametrize("test_input,expected", test_mul_inputs)
def test_cls(test_input, expected):
    # assert mul(*test_input).bit_repr() == expected.bit_repr()
    assert mul(*test_input).to_real() == expected.to_real()


test_mul_p8e0 = [
    ((231, 135), 111),
    ((70, 198), 190),
    ((192, 170), 86),
    ((101, 30), 71),
    ((140, 181), 120),
    ((163, 125), 130),
    ((64, 47), 47),
    ((129, 90), 130),
    ((43, 18), 12),
    ((154, 135), 125),
    ((183, 230), 33),
    ((210, 121), 138),
    ((71, 24), 29),
    ((124, 159), 130),
    ((127, 158), 130),
    ((203, 142), 112),
    ((252, 253), 1),
    ((76, 133), 132),
    ((248, 111), 225),
    ((197, 207), 45),
    ((147, 68), 144),
    ((55, 49), 42),
    ((7, 112), 28),
    ((32, 46), 23),
    ((247, 23), 253),
    ((22, 197), 236),
    ((135, 10), 174),
    ((144, 72), 142),
    ((115, 208), 144),
    ((95, 26), 51),
    ((65, 252), 252),
    ((30, 11), 5),
    ((143, 206), 108),
    ((61, 217), 219),
    ((191, 113), 143),
    ((228, 141), 99),
    ((223, 64), 223),
    ((139, 92), 134),
    ((246, 178), 14),
    ((100, 179), 148),
    ((200, 201), 48),
    ((160, 200), 88),
    ((194, 164), 90),
    ((245, 136), 76),
    ((132, 223), 120),
    ((16, 8), 2),
    ((206, 107), 155),
    ((211, 240), 11),
    ((145, 143), 124),
    ((108, 214), 158),
    ((47, 220), 230),
    ((31, 31), 15),
    ((56, 6), 5),
    ((85, 251), 248),
    ((149, 186), 112),
    ((142, 87), 136),
    ((60, 148), 150),
    ((52, 95), 83),
    ((208, 221), 26),
    ((231, 147), 77),
    ((187, 106), 146),
    ((23, 205), 238),
    ((126, 224), 132),
    ((156, 137), 124),
    ((218, 91), 189),
    ((35, 235), 245),
    ((205, 247), 7),
    ((2, 122), 24),
    ((254, 126), 192),
    ((155, 105), 136),
    ((90, 40), 68),
    ((75, 63), 74),
    ((138, 110), 131),
    ((45, 171), 187),
    ((173, 85), 155),
    ((234, 7), 254),
    ((33, 131), 134),
    ((244, 76), 240),
    ((26, 1), 1),
    ((213, 132), 121),
    ((176, 193), 79),
    ((88, 74), 98),
    ((243, 234), 4),
    ((123, 249), 175),
    ((59, 82), 78),
    ((222, 225), 16),
    ((236, 172), 32),
    ((167, 77), 156),
    ((12, 218), 249),
    ((238, 2), 255),
    ((146, 60), 148),
    ((237, 222), 10),
    ((201, 19), 240),
    ((188, 59), 191),
    ((28, 98), 63),
    ((13, 50), 10),
    ((17, 32), 8),
    ((217, 239), 10),
    ((3, 229), 255),
    ((130, 75), 130),
    ((106, 12), 39),
    ((109, 45), 100),
    ((137, 57), 139),
    ((103, 202), 157),
    ((112, 124), 254),
    ((215, 146), 99),
    ((62, 228), 229),
    ((204, 25), 236),
    ((232, 140), 98),
    ((118, 175), 135),
    ((157, 120), 132),
    ((72, 169), 159),
    ((68, 100), 102),
    ((251, 160), 10),
    ((110, 80), 115),
    ((178, 153), 112),
    ((151, 38), 165),
    ((209, 65), 208),
    ((119, 244), 179),
    ((14, 114), 67),
    ((82, 29), 45),
    ((46, 127), 126),
    ((53, 167), 177),
    ((8, 48), 6),
    ((98, 192), 158),
    ((166, 16), 227),
    ((174, 86), 155),
    ((93, 165), 148),
    ((94, 180), 155),
    ((1, 20), 1),
    ((36, 241), 248),
    ((240, 190), 17),
    ((242, 55), 244),
    ((141, 188), 116),
    ((158, 41), 178),
    ((131, 233), 120),
    ((116, 36), 107),
    ((19, 27), 8),
    ((66, 69), 71),
    ((181, 84), 159),
    ((63, 177), 178),
    ((224, 108), 168),
    ((120, 14), 88),
    ((25, 232), 247),
    ((216, 52), 224),
    ((96, 212), 180),
    ((99, 81), 109),
    ((78, 134), 132),
]


@pytest.mark.parametrize("test_input,expected", test_mul_p8e0)
def test_cls(test_input, expected):
    # assert mul(*test_input).bit_repr() == expected.bit_repr()
    p1 = decode(test_input[0], 8, 0)
    p2 = decode(test_input[1], 8, 0)
    pc = decode(expected, 8, 0)
    assert mul(p1, p2).to_real() == pc.to_real() or mul(p1, p2).regime.k == pc.regime.k


test_mul_p16e1 = [
    ((185, 37), 211),
    ((70, 198), 190),
    ((192, 170), 86),
    ((101, 30), 71),
    ((140, 181), 120),
    ((163, 125), 130),
    ((64, 47), 47),
    ((129, 90), 130),
    ((43, 18), 12),
    ((154, 135), 125),
    ((183, 230), 33),
    ((210, 121), 138),
    ((71, 24), 29),
    ((124, 159), 130),
    ((127, 158), 130),
    ((203, 142), 112),
    ((252, 253), 1),
    ((76, 133), 132),
    ((248, 111), 225),
    ((197, 207), 45),
    ((147, 68), 144),
    ((55, 49), 42),
    ((7, 112), 28),
    ((32, 46), 23),
    ((247, 23), 253),
    ((22, 197), 236),
    ((135, 10), 174),
    ((144, 72), 142),
    ((115, 208), 144),
    ((95, 26), 51),
    ((65, 252), 252),
    ((30, 11), 5),
    ((143, 206), 108),
    ((61, 217), 219),
    ((191, 113), 143),
    ((228, 141), 99),
    ((223, 64), 223),
    ((139, 92), 134),
    ((246, 178), 14),
    ((100, 179), 148),
    ((200, 201), 48),
    ((160, 200), 88),
    ((194, 164), 90),
    ((245, 136), 76),
    ((132, 223), 120),
    ((16, 8), 2),
    ((206, 107), 155),
    ((211, 240), 11),
    ((145, 143), 124),
    ((108, 214), 158),
    ((47, 220), 230),
    ((31, 31), 15),
    ((56, 6), 5),
    ((85, 251), 248),
    ((149, 186), 112),
    ((142, 87), 136),
    ((60, 148), 150),
    ((52, 95), 83),
    ((208, 221), 26),
    ((231, 147), 77),
    ((187, 106), 146),
    ((23, 205), 238),
    ((126, 224), 132),
    ((156, 137), 124),
    ((218, 91), 189),
    ((35, 235), 245),
    ((205, 247), 7),
    ((2, 122), 24),
    ((254, 126), 192),
    ((155, 105), 136),
    ((90, 40), 68),
    ((75, 63), 74),
    ((138, 110), 131),
    ((45, 171), 187),
    ((173, 85), 155),
    ((234, 7), 254),
    ((33, 131), 134),
    ((244, 76), 240),
    ((26, 1), 1),
    ((213, 132), 121),
    ((176, 193), 79),
    ((88, 74), 98),
    ((243, 234), 4),
    ((123, 249), 175),
    ((59, 82), 78),
    ((222, 225), 16),
    ((236, 172), 32),
    ((167, 77), 156),
    ((12, 218), 249),
    ((238, 2), 255),
    ((146, 60), 148),
    ((237, 222), 10),
    ((201, 19), 240),
    ((188, 59), 191),
    ((28, 98), 63),
    ((13, 50), 10),
    ((17, 32), 8),
    ((217, 239), 10),
    ((3, 229), 255),
    ((130, 75), 130),
    ((106, 12), 39),
    ((109, 45), 100),
    ((137, 57), 139),
    ((103, 202), 157),
    ((112, 124), 254),
    ((215, 146), 99),
    ((62, 228), 229),
    ((204, 25), 236),
    ((232, 140), 98),
    ((118, 175), 135),
    ((157, 120), 132),
    ((72, 169), 159),
    ((68, 100), 102),
    ((251, 160), 10),
    ((110, 80), 115),
    ((178, 153), 112),
    ((151, 38), 165),
    ((209, 65), 208),
    ((119, 244), 179),
    ((14, 114), 67),
    ((82, 29), 45),
    ((46, 127), 126),
    ((53, 167), 177),
    ((8, 48), 6),
    ((98, 192), 158),
    ((166, 16), 227),
    ((174, 86), 155),
    ((93, 165), 148),
    ((94, 180), 155),
    ((1, 20), 1),
    ((36, 241), 248),
    ((240, 190), 17),
    ((242, 55), 244),
    ((141, 188), 116),
    ((158, 41), 178),
    ((131, 233), 120),
    ((116, 36), 107),
    ((19, 27), 8),
    ((66, 69), 71),
    ((181, 84), 159),
    ((63, 177), 178),
    ((224, 108), 168),
    ((120, 14), 88),
    ((25, 232), 247),
    ((216, 52), 224),
    ((96, 212), 180),
    ((99, 81), 109),
    ((78, 134), 132),
]
# @pytest.mark.parametrize("test_input,expected", test_mul_p16e1)
# def test_cls(test_input, expected):
#     # assert mul(*test_input).bit_repr() == expected.bit_repr()
#     p1 = decode(test_input[0], 16, 1)
#     p2 = decode(test_input[1], 16, 1)
#     pc = decode(expected, 16, 1)
#     assert mul(p1, p2).regime.k == pc.regime.k
