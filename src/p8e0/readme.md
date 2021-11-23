


P<8,0> multiplier waveforms

![](https://www.dropbox.com/s/2nb9mkhmhwajb7q/Screen%20Shot%202021-11-17%20at%2012.58.51%20PM.png?raw=1)


steps to reproduce:
(see [here](https://bitbucket.org/riscv-ppu/ppu/src/urbani/readme.md#cli-tools))

```sh    
python tb_gen.py # generates testbench file `tb_p8e0_mul.sv`

iverilog -g2012 -D PROBE_SIGNALS p8e0_mul.sv tb_p8e0_mul.sv

./a.out

gtkwave tb_p8e0_mul.vcd # opens generated waveform with gtkwave

gtkwave tb_p8e0_mul.gtkw # opens pre-cooked waveform with gtkwave. only works if companion vcd file is present, i.e. `tb_p8e0_mul.vcd`
```



run tests?
```sh
pytest p8e0.py -v
```