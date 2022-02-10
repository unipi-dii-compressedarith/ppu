import re
import pathlib
from typing import Tuple, List
from hardposit import from_bits

N, ES = 16, 1


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
    rms /= (len(arr) - count_nans)
    rms = rms ** 0.5
    return rms


def main():
    LOG_FILE = pathlib.Path("../waveforms/comparison_against_pacogen.log")
    with open(LOG_FILE, "r") as f:
        content = f.read()

    test_failed_count = content.count("ERROR")

    REGEX_HEX_NUM = r"0x[0-9a-f]{4}"
    REGEX_SEQUENCE = "({0}) / ({0}) = ({0}) != ({0})".format(REGEX_HEX_NUM)

    tests = []
    for match in re.compile(REGEX_SEQUENCE).finditer(content):
        tests.append(match.groups())

    rms = compute_rms(tests)
    print(f"rms = {rms}")

    REGEX_NUM_TESTS = r"Total tests cases: (\d+)"
    for match in re.compile(REGEX_NUM_TESTS).finditer(content):
        num_total_tests = int(match.group(1))

    print(
        f"{test_failed_count}/{num_total_tests} = {100*test_failed_count/num_total_tests:.5g}%"
    )


if __name__ == "__main__":
    main()
