import numpy as np
import matplotlib.pyplot as plt
from posit_playground import from_bits, from_double


NUM_POINTS = 1000
MIN, MAX = 0.05, 1.2


def mask(n):
    return (1 << n) - 1


def inv_posit(X, N, ES):
    msb = 1 << (N - 1)

    sign_mask = (~((msb | (msb - 1)) >> 1)) & mask(N)
    Y = (X ^ (~sign_mask)) & mask(N)
    Y2 = (X ^ (~msb)) & mask(N)

    return Y, Y2 + 1


def inv(x, N, ES):
    X = from_double(x, N, ES).bit_repr()
    Y, Y2 = inv_posit(X, N, ES)
    y = from_bits(Y, N, ES).eval()
    y2 = from_bits(Y2, N, ES).eval()
    return y, y2


def inv_double(x):
    return 1 / x


def main():
    N, ES = 8, 0
    colors = ["blue", "green", "purple", "black", "brown", "cyan"]
    x = np.linspace(MIN, MAX, NUM_POINTS)

    for N in range(8, 11):
        y = []
        y2 = []
        for i in x:
            y.append(inv(i, N, ES)[0])
            # y2.append(inv(i, N, ES)[1])

        plt.plot(x, y, color=colors[N - 5], label=f"P<{N},{ES}>", linewidth=0.8)
        # plt.plot(x, y2, color='green', label=f"P<{N},{ES}>")

    plt.plot(x, inv_double(x), color="red", label="real", linewidth=0.4)
    plt.xlim(MIN, MAX)
    plt.grid(True)
    plt.legend()
    plt.savefig("inv.svg", format="svg")
    print(x, y)


if __name__ == "__main__":
    main()
