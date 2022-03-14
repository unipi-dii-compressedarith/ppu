# PPU


### usage:

- install prerequisites:
    
    - [cli tools](#cli_tools)
    - [`hardposit`](https://github.com/urbanij/hardposit) (required for test benches generation).

- generate all the waveforms. (unless otherwise specified all the commands are meant to be run from $PPU_ROOT).
```sh
make 
```

The design is customizable in terms of Posit format, operations supported and internal implementations details via macros and preprocessor `ifdef`s, 
e.g.:

- bare bone PPU (+ run its testbench) with add/sub/mul/div for P<8,0> for 32 bits cpu:
```sh
make ppu WORD=32 N=8 ES=0 F=0
```
- PPU for P<16,1> + conversions to double precision floating point (f64)
```sh
make ppu WORD=64 N=8 ES=0 F=64
```

- PPU for P<16,0> + conversions to double precision floating point (f64) using LUT to precompute reciprocate of mantissa
```sh
make ppu WORD=64 N=16 ES=0 F=64 DIV_WITH_LUT=1 LUT_SIZE_IN=8 LUT_SIZE_OUT=9
```








### cli tools

|   |linux                 |macOS                        |                |
|---|----------------------|-----------------------------|----------------|
|[1]|`apt install gtkwave` |`brew install gtkwave`       |~5 MB           |
|[2]|`apt install iverilog`|`brew install icarus-verilog`|~7 MB           |
|[3]|`apt install yosys`   |`brew install yosys`         |optional, ~33 MB|
|[4]| follow readme instructions | follow readme instructions |~7 MB |

---

[1] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

[2] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog)

[3] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

[4] [https://github.com/zachjs/sv2v](https://github.com/zachjs/sv2v)
