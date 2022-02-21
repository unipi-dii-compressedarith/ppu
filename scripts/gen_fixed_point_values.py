"""
python gen_fixed_point_values.py | pbcopy 
and paste into src/constants.sv

"""

from fixed2float import to_Fx

lower, upper = 5, 33

for n in range(lower, upper):
    num_bits = n
    fp_1_466 = to_Fx(1.466, 1, num_bits)
    print(f"parameter fp_1_466___N{n} = {num_bits}'d{fp_1_466.val};")


for n in range(lower, upper):
    num_bits = 2 * n - 1
    fp_1_0012 = to_Fx(1.0012, 1, num_bits)
    print(f"parameter fp_1_0012___N{n} = {num_bits}'d{fp_1_0012.val};")


for n in range(lower, upper):
    num_bits = 2 * n
    fp_2 = to_Fx(2, 2, num_bits)
    print(f"parameter fp_2___N{n} = {num_bits}'d{fp_2.val};")
