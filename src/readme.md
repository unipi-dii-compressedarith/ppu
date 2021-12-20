```sh
$ tree -t -L 1
.
├── calc_regime_bits.sv
├── cls.sv              # count leading set leftwise: (val=1)  f(0b111010) -> 3
├── highest_set.sv      # outputs leftmost 1 in a sequence
├── mul.sv              # wrapper around the whole mul operation
├── mul_core.sv         # core mul
├── posit_decode.sv     # outputs 4 different fields of a sequence of bit interpreted as P<N,ES>
├── posit_encode.sv     # output a posit P<N,ES> after taking as input sign, regime, exponent, mantissa
├
├── ppu.sv
└── ppu_pkg.sv
```
