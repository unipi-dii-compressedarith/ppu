#!/usr/bin/env python
"""
sv2v p8e0_mul.sv p8e0_pkg.sv > out.v && yosys -p "synth_intel -family max10 -top p8e0_mul -vqm p8e0_mul.vqm" out.v > yosys_intel.out

./count_latch_inferred.py yosys_intel.out
"""
import sys
import os

try:
    file = sys.argv[1]
    if file not in os.listdir("."):
        print(f"{file} not in current dir")
        exit(1)
except:
    print("give me a file")
    exit(1)


with open(file, "r") as f:
    content = f.read()

num = content.count("Latch inferred for signal")
print(f"{num} inferred latches in {file}")
