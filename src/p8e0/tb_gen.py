import softposit as sp
import random
import datetime

import p8e0_mul

N = 8 # num bits

NUM_RANDOM_TEST_CASES = 80
TEST_ALL_COMBINATIONS = False

random.seed(3)

ans = f"""/*-------------------------------------+
 | autogenerated by tb_gen.py on       |
 | {datetime.datetime.now().strftime('%c')}            |
 +-------------------------------------*/
"""
  
with open("tb_p8e0_mul.template.sv", "r") as f:
    ans += f.read()



if TEST_ALL_COMBINATIONS:
    list_a = []
    list_b = []
    for i in range(2**N):
        for j in range(i, 2**N):
            list_a.append(i)
            list_b.append(j)
    print(f"{len(list_a)=}")
else: # test NUM_RANDOM_TEST_CASES tests. 
    list_a = [random.randint(0, 2**N - 1) for _ in range(NUM_RANDOM_TEST_CASES)]
    list_b = [random.randint(0, 2**N - 1) for _ in range(NUM_RANDOM_TEST_CASES)]

# print 8-bits hex or bin repr of `val`. _bin(3) = "0b00000011"
_hex = lambda val: f"8'h{val:02x}"
_bin = lambda val: f"8'b{val:08b}"


# add 0 and NaR inputs testcases first
list_a = [0x00, 0x80] + list_a 
list_b = [0x03, 0x90] + list_b

body = ""
counter = 0
for a, b in zip(list_a, list_b):
    ans_p8e0_mul = p8e0_mul.p8e0_mul(a, b)

    ui_a = ans_p8e0_mul.ui_a
    ui_b = ans_p8e0_mul.ui_b
    z = ans_p8e0_mul.z
    k_a = ans_p8e0_mul.k_a
    k_b = ans_p8e0_mul.k_b
    k_c = ans_p8e0_mul.k_c
    frac_a = ans_p8e0_mul.frac_a
    frac_b = ans_p8e0_mul.frac_b
    frac16 = ans_p8e0_mul.frac16
    rcarry = ans_p8e0_mul.rcarry

    # a
    counter += 1
    
    body += f"""    
                    test_no =   {counter};
                    a =         {_hex(a)}; /* {sp.posit8(bits=a)} */
                    b =         {_hex(b)}; /* {sp.posit8(bits=b)} */
                    a_ascii =   \"{sp.posit8(bits=a)}\";
                    b_ascii =   \"{sp.posit8(bits=b)}\";
                    ui_a_exp =  {_hex(ui_a)};
                    ui_b_exp =  {_hex(ui_b)};
                    k_a_exp =   {k_a};
                    k_b_exp =   {k_b};
                    k_c_exp =   {k_c};
                    frac_a_exp = {_hex(frac_a)};
                    frac_b_exp = {_hex(frac_b)};
                    frac16_exp = 16'h{frac16:04x};
                    rcarry_exp = {1 if rcarry else 0};
                    z_exp      = {_hex(z)}; /* {sp.posit8(bits=z)} */
                    z_ascii    = \"{sp.posit8(bits=z)}\";
        #10;
    """


PLACEHOLDER = "/*{add stuff here}*/"
ans = ans.replace(PLACEHOLDER, body)

ans = ans.replace('\t', ' '*4)


output = "tb_p8e0_mul.sv"
with open(output, "w") as f: 
    print(f'Wrote {output}; {f.write(ans)} characters')
