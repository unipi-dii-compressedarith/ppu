"""
conjectured way of Pacogen LUT's generation with N addresses and M sized outputs.

python pacogen_mant_recip_LUT_gen.py > LUT.txt
"""

import fixed2float as f2f

N = 8
M = 9


def compute_frac_recip_val(frac_val):
    mant = (1 << N) + frac_val  # 1.frac

    fp_mant = f2f.Fx(mant, 1, N + 1)

    mant_recip = f2f.to_Fx(1.0 / fp_mant.eval(), 1, 1 + M)

    frac_recip_val = mant_recip.val & ~(1 << M)
    return frac_recip_val


for frac in range(0, 1 << N):
    print(
        f"{N}'d{frac} :    dout <= {M}'h{hex(compute_frac_recip_val(frac)).replace('0x','')}"
    )
