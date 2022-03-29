import re
from hardposit import from_bits
from pathlib import Path

N, ES = 16, 1

with open(Path("../sim/waveforms/output.log"), "r") as f:
    content = f.read()


ops = {
    0: '+',
    1: '-',
    2: '*',
    3: '/',
}

REGEX_INPUT = r"i (\w+) (\d) (\w+)"
REGEX_OUTPUT = r"o (\w+)"


inputs = []
for match in re.compile(REGEX_INPUT).finditer(content):
    inputs.append(match.groups())

outputs = []
for match in re.compile(REGEX_OUTPUT).finditer(content):
    outputs.append(match.group(1))


for i in range(len(inputs)):
    a = int(inputs[i][0], 16)
    op = ops[int(inputs[i][1])]
    b = int(inputs[i][2], 16)
    c = int(outputs[i], 16)

    pa = from_bits(a, N, ES)
    pb = from_bits(b, N, ES)
    pc = from_bits(c, N, ES)
    print(f"a {op} b", end='\t\t')
    match op:
        case '+': 
            print((pa + pb).to_bits(), pc.to_bits())
        case '-': 
            print((pa - pb).to_bits(), pc.to_bits())
        case '*': 
            print((pa * pb).to_bits(), pc.to_bits())
        case '/': 
            print((pa / pb).to_bits(), pc.to_bits())
        case _: 
            raise Exception()
