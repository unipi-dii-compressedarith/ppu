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

    exp_carry = bool((exp & msb(es + 1)) != 0).real
    if exp_carry == 1:
        k += 1
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
        exp=exp,
        mant=mant,
    )


if __name__ == "__main__":

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
    ((decode(0b00000001, 8, 0), decode(0b01111111, 8, 0)), decode(0b01000000, 8, 0)),
    (
        (
            decode(0b00111001110110111000000110101010, 32, 2),
            decode(0b01100000001111111100000111111001, 32, 2),
        ),
        decode(0b01011010011110001010000011101001, 32, 2),
    ),
    ((decode(127, 8, 0), decode(197, 8, 0)), decode(129, 8, 0)),
    ((decode(185, 8, 0), decode(37, 8, 0)), decode(211, 8, 0)),
    ((decode(70, 8, 0), decode(198, 8, 0)), decode(190, 8, 0)),
    ((decode(192, 8, 0), decode(170, 8, 0)), decode(86, 8, 0)),
    ((decode(101, 8, 0), decode(30, 8, 0)), decode(71, 8, 0)),
    ((decode(140, 8, 0), decode(181, 8, 0)), decode(120, 8, 0)),
    ((decode(163, 8, 0), decode(125, 8, 0)), decode(130, 8, 0)),
    ((decode(64, 8, 0), decode(47, 8, 0)), decode(47, 8, 0)),
    ((decode(129, 8, 0), decode(90, 8, 0)), decode(130, 8, 0)),
    ((decode(43, 8, 0), decode(18, 8, 0)), decode(12, 8, 0)),
    ((decode(154, 8, 0), decode(135, 8, 0)), decode(127, 8, 0)),
    ((decode(183, 8, 0), decode(230, 8, 0)), decode(33, 8, 0)),
    ((decode(210, 8, 0), decode(121, 8, 0)), decode(138, 8, 0)),
    ((decode(71, 8, 0), decode(24, 8, 0)), decode(29, 8, 0)),
    ((decode(124, 8, 0), decode(159, 8, 0)), decode(130, 8, 0)),
    ((decode(127, 8, 0), decode(158, 8, 0)), decode(130, 8, 0)),
    ((decode(203, 8, 0), decode(142, 8, 0)), decode(112, 8, 0)),
    ((decode(252, 8, 0), decode(253, 8, 0)), decode(1, 8, 0)),
    ((decode(76, 8, 0), decode(133, 8, 0)), decode(132, 8, 0)),
    ((decode(248, 8, 0), decode(111, 8, 0)), decode(225, 8, 0)),
    ((decode(197, 8, 0), decode(207, 8, 0)), decode(45, 8, 0)),
    ((decode(147, 8, 0), decode(68, 8, 0)), decode(144, 8, 0)),
    ((decode(55, 8, 0), decode(49, 8, 0)), decode(42, 8, 0)),
    ((decode(7, 8, 0), decode(112, 8, 0)), decode(28, 8, 0)),
    ((decode(32, 8, 0), decode(46, 8, 0)), decode(23, 8, 0)),
    ((decode(247, 8, 0), decode(23, 8, 0)), decode(253, 8, 0)),
    ((decode(22, 8, 0), decode(197, 8, 0)), decode(236, 8, 0)),
    ((decode(135, 8, 0), decode(10, 8, 0)), decode(174, 8, 0)),
    ((decode(144, 8, 0), decode(72, 8, 0)), decode(142, 8, 0)),
    ((decode(115, 8, 0), decode(208, 8, 0)), decode(144, 8, 0)),
    ((decode(95, 8, 0), decode(26, 8, 0)), decode(51, 8, 0)),
    ((decode(65, 8, 0), decode(252, 8, 0)), decode(252, 8, 0)),
    ((decode(30, 8, 0), decode(11, 8, 0)), decode(5, 8, 0)),
    ((decode(143, 8, 0), decode(206, 8, 0)), decode(108, 8, 0)),
    ((decode(61, 8, 0), decode(217, 8, 0)), decode(219, 8, 0)),
    ((decode(191, 8, 0), decode(113, 8, 0)), decode(143, 8, 0)),
    ((decode(228, 8, 0), decode(141, 8, 0)), decode(99, 8, 0)),
    ((decode(223, 8, 0), decode(64, 8, 0)), decode(223, 8, 0)),
    ((decode(139, 8, 0), decode(92, 8, 0)), decode(134, 8, 0)),
    ((decode(246, 8, 0), decode(178, 8, 0)), decode(14, 8, 0)),
    ((decode(100, 8, 0), decode(179, 8, 0)), decode(148, 8, 0)),
    ((decode(200, 8, 0), decode(201, 8, 0)), decode(48, 8, 0)),
    ((decode(160, 8, 0), decode(200, 8, 0)), decode(88, 8, 0)),
    ((decode(194, 8, 0), decode(164, 8, 0)), decode(90, 8, 0)),
    ((decode(245, 8, 0), decode(136, 8, 0)), decode(76, 8, 0)),
    ((decode(132, 8, 0), decode(223, 8, 0)), decode(120, 8, 0)),
    ((decode(16, 8, 0), decode(8, 8, 0)), decode(2, 8, 0)),
    ((decode(206, 8, 0), decode(107, 8, 0)), decode(155, 8, 0)),
    ((decode(211, 8, 0), decode(240, 8, 0)), decode(11, 8, 0)),
    ((decode(145, 8, 0), decode(143, 8, 0)), decode(124, 8, 0)),
    ((decode(108, 8, 0), decode(214, 8, 0)), decode(158, 8, 0)),
    ((decode(47, 8, 0), decode(220, 8, 0)), decode(230, 8, 0)),
    ((decode(31, 8, 0), decode(31, 8, 0)), decode(15, 8, 0)),
    ((decode(56, 8, 0), decode(6, 8, 0)), decode(5, 8, 0)),
    ((decode(85, 8, 0), decode(251, 8, 0)), decode(248, 8, 0)),
    ((decode(149, 8, 0), decode(186, 8, 0)), decode(112, 8, 0)),
    ((decode(142, 8, 0), decode(87, 8, 0)), decode(136, 8, 0)),
    ((decode(60, 8, 0), decode(148, 8, 0)), decode(150, 8, 0)),
    ((decode(52, 8, 0), decode(95, 8, 0)), decode(83, 8, 0)),
    ((decode(208, 8, 0), decode(221, 8, 0)), decode(26, 8, 0)),
    ((decode(231, 8, 0), decode(147, 8, 0)), decode(77, 8, 0)),
    ((decode(187, 8, 0), decode(106, 8, 0)), decode(146, 8, 0)),
    ((decode(23, 8, 0), decode(205, 8, 0)), decode(238, 8, 0)),
    ((decode(126, 8, 0), decode(224, 8, 0)), decode(132, 8, 0)),
    ((decode(156, 8, 0), decode(137, 8, 0)), decode(124, 8, 0)),
    ((decode(218, 8, 0), decode(91, 8, 0)), decode(189, 8, 0)),
    ((decode(35, 8, 0), decode(235, 8, 0)), decode(245, 8, 0)),
    ((decode(205, 8, 0), decode(247, 8, 0)), decode(7, 8, 0)),
    ((decode(2, 8, 0), decode(122, 8, 0)), decode(24, 8, 0)),
    ((decode(254, 8, 0), decode(126, 8, 0)), decode(192, 8, 0)),
    ((decode(155, 8, 0), decode(105, 8, 0)), decode(136, 8, 0)),
    ((decode(90, 8, 0), decode(40, 8, 0)), decode(68, 8, 0)),
    ((decode(75, 8, 0), decode(63, 8, 0)), decode(74, 8, 0)),
    ((decode(138, 8, 0), decode(110, 8, 0)), decode(131, 8, 0)),
    ((decode(45, 8, 0), decode(171, 8, 0)), decode(187, 8, 0)),
    ((decode(173, 8, 0), decode(85, 8, 0)), decode(155, 8, 0)),
    ((decode(234, 8, 0), decode(7, 8, 0)), decode(254, 8, 0)),
    ((decode(33, 8, 0), decode(131, 8, 0)), decode(134, 8, 0)),
    ((decode(244, 8, 0), decode(76, 8, 0)), decode(240, 8, 0)),
    ((decode(26, 8, 0), decode(1, 8, 0)), decode(1, 8, 0)),
    ((decode(213, 8, 0), decode(132, 8, 0)), decode(121, 8, 0)),
    ((decode(176, 8, 0), decode(193, 8, 0)), decode(79, 8, 0)),
    ((decode(88, 8, 0), decode(74, 8, 0)), decode(98, 8, 0)),
    ((decode(243, 8, 0), decode(234, 8, 0)), decode(4, 8, 0)),
    ((decode(123, 8, 0), decode(249, 8, 0)), decode(175, 8, 0)),
    ((decode(59, 8, 0), decode(82, 8, 0)), decode(78, 8, 0)),
    ((decode(222, 8, 0), decode(225, 8, 0)), decode(16, 8, 0)),
    ((decode(236, 8, 0), decode(172, 8, 0)), decode(32, 8, 0)),
    ((decode(167, 8, 0), decode(77, 8, 0)), decode(156, 8, 0)),
    ((decode(12, 8, 0), decode(218, 8, 0)), decode(249, 8, 0)),
    ((decode(238, 8, 0), decode(2, 8, 0)), decode(255, 8, 0)),
    ((decode(146, 8, 0), decode(60, 8, 0)), decode(148, 8, 0)),
    ((decode(237, 8, 0), decode(222, 8, 0)), decode(10, 8, 0)),
    ((decode(201, 8, 0), decode(19, 8, 0)), decode(240, 8, 0)),
    ((decode(188, 8, 0), decode(59, 8, 0)), decode(191, 8, 0)),
    ((decode(28, 8, 0), decode(98, 8, 0)), decode(63, 8, 0)),
    ((decode(13, 8, 0), decode(50, 8, 0)), decode(10, 8, 0)),
    ((decode(17, 8, 0), decode(32, 8, 0)), decode(8, 8, 0)),
    ((decode(217, 8, 0), decode(239, 8, 0)), decode(10, 8, 0)),
    ((decode(3, 8, 0), decode(229, 8, 0)), decode(255, 8, 0)),
    ((decode(130, 8, 0), decode(75, 8, 0)), decode(130, 8, 0)),
    ((decode(106, 8, 0), decode(12, 8, 0)), decode(39, 8, 0)),
    ((decode(109, 8, 0), decode(45, 8, 0)), decode(100, 8, 0)),
    ((decode(137, 8, 0), decode(57, 8, 0)), decode(139, 8, 0)),
    ((decode(103, 8, 0), decode(202, 8, 0)), decode(157, 8, 0)),
    ((decode(112, 8, 0), decode(124, 8, 0)), decode(254, 8, 0)),
    ((decode(215, 8, 0), decode(146, 8, 0)), decode(99, 8, 0)),
    ((decode(62, 8, 0), decode(228, 8, 0)), decode(229, 8, 0)),
    ((decode(204, 8, 0), decode(25, 8, 0)), decode(236, 8, 0)),
    ((decode(232, 8, 0), decode(140, 8, 0)), decode(98, 8, 0)),
    ((decode(118, 8, 0), decode(175, 8, 0)), decode(135, 8, 0)),
    ((decode(157, 8, 0), decode(120, 8, 0)), decode(132, 8, 0)),
    ((decode(72, 8, 0), decode(169, 8, 0)), decode(159, 8, 0)),
    ((decode(68, 8, 0), decode(100, 8, 0)), decode(102, 8, 0)),
    ((decode(251, 8, 0), decode(160, 8, 0)), decode(10, 8, 0)),
    ((decode(110, 8, 0), decode(80, 8, 0)), decode(115, 8, 0)),
    ((decode(178, 8, 0), decode(153, 8, 0)), decode(112, 8, 0)),
    ((decode(151, 8, 0), decode(38, 8, 0)), decode(165, 8, 0)),
    ((decode(209, 8, 0), decode(65, 8, 0)), decode(208, 8, 0)),
    ((decode(119, 8, 0), decode(244, 8, 0)), decode(179, 8, 0)),
    ((decode(14, 8, 0), decode(114, 8, 0)), decode(67, 8, 0)),
    ((decode(82, 8, 0), decode(29, 8, 0)), decode(45, 8, 0)),
    ((decode(46, 8, 0), decode(127, 8, 0)), decode(126, 8, 0)),
    ((decode(53, 8, 0), decode(167, 8, 0)), decode(177, 8, 0)),
    ((decode(8, 8, 0), decode(48, 8, 0)), decode(6, 8, 0)),
    ((decode(98, 8, 0), decode(192, 8, 0)), decode(158, 8, 0)),
    ((decode(166, 8, 0), decode(16, 8, 0)), decode(227, 8, 0)),
    ((decode(174, 8, 0), decode(86, 8, 0)), decode(155, 8, 0)),
    ((decode(93, 8, 0), decode(165, 8, 0)), decode(148, 8, 0)),
    ((decode(94, 8, 0), decode(180, 8, 0)), decode(155, 8, 0)),
    ((decode(1, 8, 0), decode(20, 8, 0)), decode(1, 8, 0)),
    ((decode(36, 8, 0), decode(241, 8, 0)), decode(248, 8, 0)),
    ((decode(240, 8, 0), decode(190, 8, 0)), decode(17, 8, 0)),
    ((decode(242, 8, 0), decode(55, 8, 0)), decode(244, 8, 0)),
    ((decode(141, 8, 0), decode(188, 8, 0)), decode(116, 8, 0)),
    ((decode(158, 8, 0), decode(41, 8, 0)), decode(178, 8, 0)),
    ((decode(131, 8, 0), decode(233, 8, 0)), decode(120, 8, 0)),
    ((decode(116, 8, 0), decode(36, 8, 0)), decode(107, 8, 0)),
    ((decode(19, 8, 0), decode(27, 8, 0)), decode(8, 8, 0)),
    ((decode(66, 8, 0), decode(69, 8, 0)), decode(71, 8, 0)),
    ((decode(181, 8, 0), decode(84, 8, 0)), decode(159, 8, 0)),
    ((decode(63, 8, 0), decode(177, 8, 0)), decode(178, 8, 0)),
    ((decode(224, 8, 0), decode(108, 8, 0)), decode(168, 8, 0)),
    ((decode(120, 8, 0), decode(14, 8, 0)), decode(88, 8, 0)),
    ((decode(25, 8, 0), decode(232, 8, 0)), decode(247, 8, 0)),
    ((decode(216, 8, 0), decode(52, 8, 0)), decode(224, 8, 0)),
    ((decode(96, 8, 0), decode(212, 8, 0)), decode(180, 8, 0)),
    ((decode(99, 8, 0), decode(81, 8, 0)), decode(109, 8, 0)),
    ((decode(78, 8, 0), decode(134, 8, 0)), decode(132, 8, 0)),
]


@pytest.mark.parametrize("test_input,expected", test_mul_inputs)
def test_cls(test_input, expected):
    # assert mul(*test_input).bit_repr() == expected.bit_repr()
    assert mul(*test_input).to_real() == expected.to_real()
