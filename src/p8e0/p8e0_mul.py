# either:
#   pytest p8e0_mul.py -v  
# or
#   python p8e0_mul.py -v

from typing import Tuple
import pytest 
import unittest
import random
import softposit as sp

# random.seed(12)
N = 8 # num bits

class Ans:
    def __init__(
        self, z, 
        ui_a=0, ui_b=0, 
        k_a=0, k_b=0, k_c=0, 
        frac_a=0, frac_b=0, frac16=0, 
        rcarry=0
    ) -> None:
        self.z = z
        self.ui_a = ui_a
        self.ui_b = ui_b
        self.k_a = k_a
        self.k_b = k_b
        self.k_c = k_c
        self.frac_a = frac_a
        self.frac_b = frac_b
        self.frac16 = frac16
        self.rcarry = rcarry


def sign_reg_ui(bits):
    return (bits & 0x40) != 0

def _separate_bits_tmp(bits):
    k = 0
    tmp = bits << 2
    if sign_reg_ui(bits):
        while (tmp & 0x80) != 0:
            k += 1
            tmp = tmp << 1
    else:
        k = -1
        while (tmp & 0x80) == 0:
            k -= 1
            tmp = tmp << 1
        tmp &= 0x7f                     # zeroes the leftmost bit
    return (k, tmp & 0xff)

def separate_bits(bits):
    # k, tmp = _separate_bits_tmp(bits)
    
    k, reg_len = calc_k(bits)

    tmp = bits << 0
    tmp = ((tmp << reg_len) & 0xff | 0x80)

    return (k, tmp)

def calc_k(bits):
    k = -6 if ( bits << 1 & 0xff) >> 1 == 1 else \
        -5 if ( bits << 1 & 0xff) >> 2 == 1 else \
        -4 if ( bits << 1 & 0xff) >> 3 == 1 else \
        -3 if ( bits << 1 & 0xff) >> 4 == 1 else \
        -2 if ( bits << 1 & 0xff) >> 5 == 1 else \
        -1 if ( bits << 1 & 0xff) >> 6 == 1 else \
         0 if (~bits << 1 & 0xff) >> 6 == 1 else \
         1 if (~bits << 1 & 0xff) >> 5 == 1 else \
         2 if (~bits << 1 & 0xff) >> 4 == 1 else \
         3 if (~bits << 1 & 0xff) >> 3 == 1 else \
         4 if (~bits << 1 & 0xff) >> 2 == 1 else \
         5 if (~bits << 1 & 0xff) >> 1 == 1 else 6
    
    reg_len = 1 + (k + 1 if sign_reg_ui(bits) == 1 else -k)
    if reg_len == 8: reg_len = 7

    return (k, reg_len)
            

def checked_shr(bits, rhs):
    # https://doc.rust-lang.org/std/primitive.u32.html#method.checked_shr
    return bits >> rhs 

def calculate_regime(k) -> Tuple[int, bool, int]:
    if k < 0:
        length = -k & 0xffff_ffff
        return (checked_shr(0x40, length), False, length)
    else:
        length = (k + 1) & 0xffff_ffff
        return (0x7f - checked_shr(0x7f, length), True, length)

def pack_to_ui(regime, frac):
    return regime + frac


def calc_ui(k, frac16):
    regime, reg_s, reg_len = calculate_regime(k)
    if reg_len > 6:
        return 0x7f if reg_s else 0x01
    else:
        frac16 = (frac16 & 0x3fff) >> reg_len
        frac = (frac16 >> 8) & 0xff
        #                    ^^^^^^ => as u8
        bit_n_plus_one = (frac16 & 0x80) != 0
        u_z = pack_to_ui(regime, frac)
        if bit_n_plus_one:
            bits_more = (frac16 & 0x7f) != 0
            u_z += (u_z & 1) | (bits_more & 0xff)
        return u_z

def from_bits(bits: int, sign: bool) -> int:
    return c2(bits) if sign else bits
    
def c2(a: int) -> int: 
    return (~a + 1) & 0xff

def is_nar(a):  return a == 0x80
def is_zero(a): return a == 0

def p8e0_mul(a: int, b: int) -> Ans:

    if is_nar(a) or is_nar(b):
        return Ans(z=0x80) # NaR
    elif is_zero(a) or is_zero(b):
        return Ans(z=0) # 0

    sign_a = a & 0x80
    sign_b = b & 0x80
    sign_z: bool = (sign_a ^ sign_b) != 0

    ui_a = a if sign_a == 0 else c2(a)
    ui_b = b if sign_b == 0 else c2(b)

    k_a, frac_a = separate_bits(ui_a)
    k_b, frac_b = separate_bits(ui_b)

    k_c = k_a + k_b

    frac_c = (frac_a * frac_b) & 0xffff # on twice the width

    rcarry = (frac_c & 0x8000) != 0

    if rcarry:
        k_c_updated = k_c + 1
        frac16 = frac_c >> 1
    else:
        k_c_updated = k_c
        frac16 = frac_c
        
    # u_z = calc_ui(k_c_updated, frac16)

    regime, reg_s, reg_len = calculate_regime(k_c_updated)
    if reg_len > 6:
        u_z = 0x7f if reg_s else 0x01
    else:
        frac16 = (frac16 & 0x3fff) >> reg_len
        u_z = regime + ((frac16 >> 8) & 0xff)
        if (frac16 & 0x80) != 0:
            bits_more = (frac16 & 0x7f) != 0
            u_z += (u_z & 1) | (bits_more & 0xff)
    
    z = from_bits(u_z, sign_z)

    return Ans(ui_a=ui_a, ui_b=ui_b, k_a=k_a, k_b=k_b, k_c=k_c_updated, 
               frac_a=frac_a, frac_b=frac_b, frac16=frac16, rcarry=rcarry, z=z)





class TestSum(unittest.TestCase):
    def test_zeros(self):
        a = 0x00
        b = random.randint(0, 2**N - 1)
        a_p8, b_p8 = sp.posit8(bits=a), sp.posit8(bits=b)
        
        z_int = p8e0_mul(a, b).z
        self.assertEqual(
            a_p8 * b_p8,
            sp.posit8(bits=z_int)
        )
    def test_nar(self):
        a = 0x80
        b = random.randint(0, 2**N - 1)
        a_p8, b_p8 = sp.posit8(bits=a), sp.posit8(bits=b)
        
        z_int = p8e0_mul(a, b).z
        self.assertEqual(
            a_p8 * b_p8,
            sp.posit8(bits=z_int)
        )

    def test_zero_times_nar(self):
        a = 0
        b = 0x80
        a_p8, b_p8 = sp.posit8(bits=a), sp.posit8(bits=b)
        
        z_int = p8e0_mul(a, b).z
        self.assertEqual(
            a_p8 * b_p8,
            sp.posit8(bits=z_int)
        )

    def test3(self):
        a = b = 0x7f
        a_p8, b_p8 = sp.posit8(bits=a), sp.posit8(bits=b)
        
        z_int = p8e0_mul(a, b).z
        self.assertEqual(
            a_p8 * b_p8,
            sp.posit8(bits=z_int)
        )

    def test_mix(self):
        for _ in range(1000):
            # 1) generate random 8bits numbers
            a = random.randint(0, 2**N - 1)
            b = random.randint(0, 2**N - 1)

            # 3) compute posit multiplication with my procedure (returns int)
            z_int = p8e0_mul(a, b).z

            a_p8, b_p8 = sp.posit8(bits=a), sp.posit8(bits=b)

            c_p8 = a_p8 * b_p8
            self.assertEqual(
                c_p8,
                sp.posit8(bits=z_int)
            )


if __name__ == '__main__':
    unittest.main()


test_k_params = [
        (0b00000001, (-6, 7)),
        (0b10001010, (-3, 4)),
        (0b10001011, (-3, 4)),
        (0b00001110, (-3, 4)),
        (0b10001000, (-3, 4)),
        (0b00001010, (-3, 4)),
        (0b01110001, ( 2, 4)),
        (0b11110010, ( 2, 4)),
        (0b11110111, ( 2, 4)),
        (0b01110100, ( 2, 4)),
        (0b01110010, ( 2, 4)),
        (0b01111111, ( 6, 7)),
        (0b11111111, ( 6, 7)),
        (0b01100011, ( 1, 3)),
        (0b11100110, ( 1, 3)),
        (0b01100111, ( 1, 3)),
        (0b11101110, ( 1, 3))]
        # └── p8e0     │  │
        #              │  └── regime length
        #              └── regime value

@pytest.mark.parametrize("test_input,expected", test_k_params)
def test_k(test_input, expected):
    assert (calc_k(test_input) == expected)



test_tmp = [
    (0b01001100, 0b10110000),
    (0b01100100, 0b10100000),
    (0b00010000, 0b10000000),
    (0b01011010, 0b11101000),
    (0b01010001, 0b11000100),
    (0b01000000, 0b10000000),
    (0b01110001, 0b10010000),
    (0b01000001, 0b10000100),
    (0b00000101, 0b10100000),
    (0b01110111, 0b11110000),
    (0b01100010, 0b10010000),
    (0b01000000, 0b10000000)]
@pytest.mark.parametrize("test_input,expected", test_tmp)
def test_tmp(test_input, expected):
        assert separate_bits(test_input)[1] == expected


NUM_RANDOM_TEST_CASES = 10
for _ in range(NUM_RANDOM_TEST_CASES):
    list_a = [random.randint(0, 2**N - 1) for _ in range(NUM_RANDOM_TEST_CASES)]
    list_b = [random.randint(0, 2**N - 1) for _ in range(NUM_RANDOM_TEST_CASES)]

    # to be finished