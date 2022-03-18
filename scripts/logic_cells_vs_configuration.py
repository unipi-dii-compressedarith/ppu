import re
from pathlib import Path
import os

N = 16
ES = 1

DIV_WITH_LUT = 1
LUT_SIZE_IN = 8
LUT_SIZE_OUT = 9
# NEWTON_RAPHSON = 1


REGEX_LOGIC_CELLS = r"(Estimated number of LCs: +)(\d+)"

os.system(
    f"make ppu WORD=64 N={N} ES={ES} F=64 DIV_WITH_LUT={DIV_WITH_LUT} LUT_SIZE_IN={LUT_SIZE_IN} LUT_SIZE_OUT={LUT_SIZE_OUT}"
)
os.system("make yosys")

with open(Path("./src/yosys_ppu_top.out"), "r") as f:
    content = f.read()

for match in re.compile(REGEX_LOGIC_CELLS).finditer(content):
    logic_cells = match.group(2)

with open(Path("logic_cells.csv"), "a") as f:
    if DIV_WITH_LUT == 0:
        LUT_SIZE_IN, LUT_SIZE_OUT = ("_", "_")
    f.write(
        f"\n{N}, {ES}, {DIV_WITH_LUT}, {LUT_SIZE_IN}, {LUT_SIZE_OUT}, {logic_cells}"
    )
