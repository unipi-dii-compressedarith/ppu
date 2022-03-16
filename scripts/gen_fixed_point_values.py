"""
python gen_fixed_point_values.py | pbcopy 
and paste into src/constants.sv

"""

from fixed2float import to_Fx

lower, upper = 4, 33  # N (posit size)
round = True

decimal = lambda fx_num, num_bits: f"{num_bits}'d{fx_num.val}"
binary = lambda fx_num, num_bits: f"{num_bits}'b{bin(fx_num.val).replace('0b','')}"


print()
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = mant_size
    fx_1_466 = to_Fx(1.466, 1, num_bits, round=round)
    print(f"parameter fx_1_466___N{n} = {decimal(fx_1_466, num_bits)};")


print()
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = 2 * mant_size - 1
    fx_1_0012 = to_Fx(1.0012, 1, num_bits, round=round)
    print(f"parameter fx_1_0012___N{n} = {decimal(fx_1_0012, num_bits)};")


print()
for n in range(lower, upper):
    mant_size = n - 2
    num_bits = 2 * mant_size
    fx_2 = to_Fx(2, 2, num_bits, round=round)
    print(f"parameter fx_2___N{n} = {decimal(fx_2, num_bits)};")
