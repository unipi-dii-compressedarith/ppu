"""
$ python tb_gen_pipelined.py | pbcopy

then paste it to tb_pipelined
"""

import random

ops = {
    0: "ADD",
    1: "SUB",
    2: "MUL",
    3: "DIV",
}

c = ""
for i in range(2000):
    valid_in = int(random.random() > 0.2)  # 80% of the time
    op = ops[int(random.random() * 4)]  # ops equally distributed
    in1 = int(random.random() * 423)
    in2 = int(random.random() * 491)
    delay = int(random.random() * 15 + 3)  # between 3 and 18
    if not valid_in:
        op = "'bz"
        in1 = "'bz"
        in2 = "'bz"

    c += f"""
ppu_valid_in = {valid_in};
ppu_op = {op};
ppu_in1 = {in1};
ppu_in2 = {in2};
#{delay};

    """

print(c)
