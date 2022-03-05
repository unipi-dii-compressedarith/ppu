Comparison of different designs of leading zero counters.


references:

[1] [Designing an Efficient Leading Zero Counter](https://youtu.be/lZ1DqG0Pn_I)
[2] [Milenković et al., Modular Design Of Fast Leading Zeros Counting Circuit](https://www.researchgate.net/publication/284919835_Modular_Design_Of_Fast_Leading_Zeros_Counting_Circuit)

Dimitrakopoulos et al., Low-Power Leading-Zero Counting and Anticipation
Logic for High-Speed Floating Point Units (https://ieeexplore.ieee.org/document/4539802)

[0] [pulp-platform's lzc](https://github.com/pulp-platform/common_cells/blob/b2a4b2d3decdfc152ad9b4564a48ed3b2649fd6c/src/lzc.sv)
+ companion math_pkg file https://github.com/pulp-platform/common_cells/blob/b2a4b2d3decdfc152ad9b4564a48ed3b2649fd6c/src/cf_math_pkg.sv

[4] [Jaiswal et al.](https://github.com/manish-kj/PACoGen/blob/5f6572c9c3862b74e158f31ada4f36942522fd89/add/posit_add.v#L327)

[5] https://github.com/ameetgohil/leading-zeroes-counter/blob/36c5e0608a48b43a3533d3d0f5a9efc70eba163b/rtl/lzc.sv


quartus LE (/40760 total) reports @ N = 32 bits
0) 36
2) 40
ours) 59
4) 41
5) 49
