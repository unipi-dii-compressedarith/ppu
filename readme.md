# PPU


### usage:

- install prerequisites:
    
    - [cli tools](#cli_tools)
    - [`hardposit`](https://github.com/urbanij/hardposit) (required for test benches generation).
- export `RISCV_PPU_DIR` env variable to point to the root of the RISCV-PPU directory (which contains at least `ppu` i.e. this repo and `PACoGen` i.e. [this](https://bitbucket.org/riscv-ppu/pacogen/src/urbani/) repo)
- generate all the waveforms. (unless otherwise specified all the commands are meant to be run from $PPU_ROOT).
```sh
make 
```

The design is customizable in terms of Posit format (P<any, any>), operations supported (e.g. including/leaving out conversions) and internal implementations details (e.g. using LUT for division or adding newton-raphson steps) via macros and preprocessor `ifdef`s, 
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


To open the waveforms run
```sh
gtkwave waveforms/tb_ppu_P16E1.vcd # [1]
```
or 
```sh
gtkwave waveforms/tb_ppu_P16E1.gtkw # [2]
```
or 
```sh
gtkwave -S gtkwave.tcl waveforms/tb_ppu_P16E1.vcd # [3]
```


### cli tools

|   |linux                 |macOS                        |                |
|---|----------------------|-----------------------------|----------------|
|[4]|`apt install gtkwave` |`brew install gtkwave`       |~5 MB           |
|[5]|`apt install iverilog`|`brew install icarus-verilog`|~7 MB           |
|[6]|`apt install yosys`   |`brew install yosys`         |optional, ~33 MB|
|[7]| follow readme instructions | follow readme instructions |~7 MB |

---
[1] ok version

[2] better version, the preloaded file you saved earlier is loaded

[3] best version, a tlc script is run, which sets the waveform in the position and format they're meant to be). Check [this](https://github.com/carlosedp/chiselv/blob/72fbbd066357fe16e79612eb678bb06bc0ff21e0/GTKWave/gtkwave.tcl) for reference.

[4] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

[5] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog)

[6] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

[7] [https://github.com/zachjs/sv2v](https://github.com/zachjs/sv2v)
