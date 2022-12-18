#!/usr/bin/env python
"""
./gen_fixed_point_values.py | pbcopy 
and paste into src/constants.sv

"""

from fixed2float import to_Fx

lower, upper = 4, 33  # N (posit size)
round = True

decimal = lambda fx_num, num_bits: f"{num_bits}'d{fx_num.val}"
binary = lambda fx_num, num_bits: f"{num_bits}'b{bin(fx_num.val).replace('0b','')}"

K1 = 1.4567844114901045
K2 = 1.0009290026616422
K3 = 2.0

print(f"\n// Fixedpoint format of {K1}")
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = mant_size
    fx_1_466 = to_Fx(K1, 1, num_bits, round=round)
    print(f"parameter fx_1_466___N{n} = {decimal(fx_1_466, num_bits)}; // Fx<1, {num_bits}>")


print(f"\n// Fixedpoint format of {K2}")
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = 2 * mant_size - 1
    fx_1_0012 = to_Fx(K2, 1, num_bits, round=round)
    print(f"parameter fx_1_0012___N{n} = {decimal(fx_1_0012, num_bits)}; // Fx<1, {num_bits}>")


print(f"\n// Fixedpoint format of {K3}")
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = 2 * mant_size
    fx_2 = to_Fx(K3, 2, num_bits, round=round)
    print(f"parameter fx_2___N{n} = {decimal(fx_2, num_bits)}; // Fx<2, {num_bits}>")
