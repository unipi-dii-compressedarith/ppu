"""
pip install posit_playground
"""

from posit_playground import posit

if __name__ == "__main__":
    N, ES = 8, 0

    p1 = posit.from_bits(0x42, N, ES)
    p2 = posit.from_bits(0x7a, N, ES)

    p1_times_p2 = p1 * p2

