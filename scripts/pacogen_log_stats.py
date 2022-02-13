import re
import pathlib
from typing import Tuple, List
from hardposit import from_bits
import argparse


parser = argparse.ArgumentParser(description="Generate test benches")
parser.add_argument("--num-bits", "-n", type=int, required=True, help="Num posit bits")
parser.add_argument("--es-size", "-es", type=int, required=True, help="Num posit bits")
args = parser.parse_args()

N, ES = args.num_bits, args.es_size


def compute_rms(arr: List[Tuple[int]]) -> float:
    rms = 0
    count_nans = 0
    for tuple in arr:
        pa = from_bits(int(tuple[0], 16), N, ES)
        pb = from_bits(int(tuple[1], 16), N, ES)
        pout_exp = pa / pb
        pout_exp_file = from_bits(int(tuple[2], 16), N, ES)
        assert pout_exp.to_hex(prefix=True) == tuple[3]

        if pout_exp.is_nan or pout_exp_file.is_nan:
            count_nans += 1
        else:
            rms += (pout_exp.eval() - pout_exp_file.eval()) ** 2

    print(f"{count_nans} nans")
    try:
        rms /= len(arr) - count_nans
    except ZeroDivisionError:
        rms = 0.0
    rms = rms ** 0.5
    return rms


def main():
    LOG_FILE = pathlib.Path(f"../waveforms/comparison_against_pacogen{N}.log")
    with open(LOG_FILE, "r") as f:
        content = f.read()

    pacogen_tests_failed = content.count("PACOGEN_ERROR")
    not_ppu_tests_failed = content.count("NOT_PPU_ERROR")

    REGEX_HEX_NUM = r"0x[0-9a-f]" + "{" + str(N // 4) + "}"
    REGEX_SEQUENCE = "({0}) / ({0}) = ({0}) != ({0})".format(REGEX_HEX_NUM)

    pacogen_tests = []
    for match in re.compile("PACOGEN_ERROR: " + REGEX_SEQUENCE).finditer(content):
        pacogen_tests.append(match.groups())

    not_ppu_tests = []
    for match in re.compile("NOT_PPU_ERROR: " + REGEX_SEQUENCE).finditer(content):
        not_ppu_tests.append(match.groups())

    pacogen_rms = compute_rms(pacogen_tests)
    print(f"pacogen_rms = {pacogen_rms}")

    not_ppu_rms = compute_rms(not_ppu_tests)
    print(f"not_ppu_rms = {not_ppu_rms}")

    REGEX_NUM_TESTS = r"Total tests cases: (\d+)"
    for match in re.compile(REGEX_NUM_TESTS).finditer(content):
        num_total_tests = int(match.group(1))

    print(
        f"pacogen wrong: {pacogen_tests_failed}/{num_total_tests} = {100*pacogen_tests_failed/num_total_tests:.5g}%"
    )

    print(
        f"not_ppu wrong: {not_ppu_tests_failed}/{num_total_tests} = {100*not_ppu_tests_failed/num_total_tests:.5g}%"
    )


if __name__ == "__main__":
    main()
