import numpy as np
import matplotlib.pyplot as plt
from posit_playground import from_bits, from_double


NUM_POINTS = 1000
MIN, MAX = 0.05, 1.2

def mask(n):
    return((1 << n) - 1)

def inv_posit(X, N, ES):
    msb = 1 << (N-1)

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
    return 1/x



def main():
    x = np.linspace(MIN, MAX, NUM_POINTS)
    
    y_8 = []
    y_16 = []
    for i in x:
        y_8.append(inv(i, 8, 0)[0])
        y_16.append(inv(i, 16, 1)[0])
    
    plt.plot(x, y_8, color='blue', label=f"P<8,0>", linewidth=0.8)
    plt.plot(x, y_16, color='cyan', label=f"P<16,1>", linewidth=0.8)
    
    plt.plot(x, inv_double(x), color='red', label="real", linewidth=0.4)
    plt.xlim(MIN, MAX)
    plt.grid(True)
    plt.legend()
    plt.savefig('inv_8_vs_16.svg', format='svg')
    
if __name__ == "__main__":
    main()
