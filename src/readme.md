```sh
$ tree -t -L 1
.
├── ppu_pkg.sv
├── _p160_p8.sv
├── _p161_p8.sv
├── _p8_p161.sv
├── fp32_p160.sv
├── fp32_p161.sv
├── fp32_p8.sv
├── fx16_p8.sv
├── reg_tb.sv
├── p16e0
├── encode8.sv
├── ppu.sv
├── highest_set.png
├── sum8.sv
├── reg16.sv
├── p161_fp32.sv
├── p160_fp32.sv
├── p8_fx16.sv
├── p8_fp32.sv
├── mul8.sv
├── ger16.sv
├── _p160_p161.sv
├── _p8_p160.sv
├── ger8.sv
├── reg8.sv
├── _p161_p160.sv
├── _p161_p160.v
├── decode8.sv             # former decode module
├── tb_posit_decode.sv
├── posit_decode.sv        # outputs 4 different fields of a sequence of bit interpreted as P<N,ES>
├── p8e0                   # p8e0 related things (~ abandoned)
├── clo.sv                 # count leading ones: f(0b111010) -> 3
├── reverse_bits.sv        # self explanatory
├── posit_encode.sv        # output a posit P<N,ES> after taking as input sign, regime, exponent, mantissa
└── highest_set.sv         # outputs leftmost 1 in a sequence

```