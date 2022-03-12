"""
conjectured way of Pacogen LUT's generation with N addresses and M sized outputs.

python pacogen_mant_recip_LUT_gen.py -i 8 -o 9 > LUT.txt
"""

import argparse
import fixed2float as f2f

parser = argparse.ArgumentParser(description="Generate LUT")

parser.add_argument("--size-in", "-i", type=int, required=True, help="Input width")
parser.add_argument("--size-out", "-o", type=int, required=True, help="Output width")

args = parser.parse_args()
N = args.size_in
M = args.size_out


def compute_frac_recip_val(frac_val):
    mant = (1 << N) + frac_val  # 1.frac

    fx_mant = f2f.Fx(mant, 1, N + 1)

    mant_recip = f2f.to_Fx(1.0 / fx_mant.eval(), 1, 1 + M)

    frac_recip_val = mant_recip.val & ~(1 << M)
    return frac_recip_val


for frac in range(0, 1 << N):
    print(
        f"{N}'d{frac} :    dout <= {M}'h{hex(compute_frac_recip_val(frac)).replace('0x','')};"
    )
