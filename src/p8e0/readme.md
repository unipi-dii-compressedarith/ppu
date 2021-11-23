


P<8,0> multiplier waveforms

![](https://www.dropbox.com/s/2nb9mkhmhwajb7q/Screen%20Shot%202021-11-17%20at%2012.58.51%20PM.png?raw=1)


### steps to reproduce:
(see [here](https://bitbucket.org/riscv-ppu/ppu/src/urbani/readme.md#cli-tools))

preparation – assuming Python is already set up on your machine

install the [softposit library](https://gitlab.com/cerlane/SoftPosit-Python) from [PyPI](https://pypi.org/project/softposit/) (Python Package Index)
```sh
pip install softposit
```

```sh
make mul
```

visualization (\*)
```sh
# opens generated waveform with gtkwave
gtkwave tb_p8e0_mul.vcd

# opens pre-cooked waveform with gtkwave. only works if companion vcd file is present, i.e. `tb_p8e0_mul.vcd`
gtkwave tb_p8e0_mul.gtkw
```


(\*) on macOS this may not work, just open gtkwave like a normal application and then File -> Open New Tab -> pick the `.gktw` or `.vcd` file you need.


run tests?
```sh
pytest p8e0.py -v
```
