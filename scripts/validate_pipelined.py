import re
from hardposit import from_bits, from_double
from hardposit.float import F32, F64
from pathlib import Path

N, ES = 16, 1

OUTPUT_LOG_FILE = "output.log"
with open(Path(f"../sim/waveforms/{OUTPUT_LOG_FILE}"), "r") as f:
    content = f.read()

print("*" * 30 + f" {OUTPUT_LOG_FILE} " + "*" * 30)
print(content)
print("*" * (30 + len(f" {OUTPUT_LOG_FILE} ") + 30))

ops = {
    0: "+",
    1: "-",
    2: "*",
    3: "/",
    4: "f2p",
    5: "p2f",
}

REGEX_INPUT = r"i (\w+) (\d) (\w+)"
REGEX_OUTPUT = r"o (\w+)"


inputs = []
for match in re.compile(REGEX_INPUT).finditer(content):
    inputs.append(match.groups())

outputs = []
for match in re.compile(REGEX_OUTPUT).finditer(content):
    outputs.append(match.group(1))

err_log = ""
err = 0

for i in range(len(inputs)):
    op = ops[int(inputs[i][1])]

    if 0 <= int(inputs[i][1]) < 4:
        a = int(inputs[i][0], 16)
        b = int(inputs[i][2], 16)
        c = int(outputs[i], 16)

        pa = from_bits(a, N, ES)
        pb = from_bits(b, N, ES)
        pc = from_bits(c, N, ES)

        match op:  # Python3.10+
            case "+":
                is_same = (pa + pb) == pc
                if not is_same:
                    err_log += (
                        f"{a} {op} {b}       ({(pa + pb).to_bits()}, {pc.to_bits()}) \n"
                    )
                err += (not is_same).real
            case "-":
                is_same = (pa - pb) == pc
                if not is_same:
                    err_log += (
                        f"{a} {op} {b}       ({(pa - pb).to_bits()}, {pc.to_bits()}) \n"
                    )
                err += (not is_same).real
            case "*":
                is_same = (pa * pb) == pc
                if not is_same:
                    err_log += (
                        f"{a} {op} {b}       ({(pa * pb).to_bits()}, {pc.to_bits()}) \n"
                    )
                err += (not is_same).real
            case "/":
                is_same = (pa / pb) == pc
                if not is_same:
                    err_log += (
                        f"{a} {op} {b}       ({(pa / pb).to_bits()}, {pc.to_bits()}) \n"
                    )
                err += (not is_same).real
            case _:
                raise Exception("wrong op")

    elif op == "f2p":
        a = int(inputs[i][0], 16)
        float = F64(bits=a)
        p = from_double(float.eval(), N, ES)
        c = int(outputs[i], 16)
        is_same = p.to_bits() == c
        if not is_same:
            err_log += f"f2p({a})\n"
        err += (not is_same).real

    elif op == "p2f":
        b = int(inputs[i][2], 16)
        # breakpoint()
        pb = from_bits(b, N, ES)
        c = int(outputs[i], 16)
        float = F64(x_f64=pb.eval())
        is_same = float.to_bits() == c
        if not is_same:
            err_log += f"p2f({b})\n"
        err += (not is_same).real
    else:
        raise Exception("wrong op")


if err != 0:
    print(err_log)


print(
    "[ OK ]"
    if err == 0
    else f"[ FAILING ] ({err}/{len(inputs)} = {100*err/len(inputs):.4g}%)"
)
