


P<8,0> multiplier waveforms

![](https://www.dropbox.com/s/2nb9mkhmhwajb7q/Screen%20Shot%202021-11-17%20at%2012.58.51%20PM.png?raw=1)


#### steps to reproduce:

(see [here](https://bitbucket.org/riscv-ppu/ppu/src/urbani/readme.md#cli-tools))

- preparation – assuming Python is already set up on your machine

install the [softposit library](https://gitlab.com/cerlane/SoftPosit-Python) from [PyPI](https://pypi.org/project/softposit/) (Python Package Index)
```sh
pip install softposit
```

```sh
make mul # (**)
```

- visualization (\*)

```sh
# opens generated waveform with gtkwave
gtkwave tb_p8e0_mul.vcd

# opens pre-cooked waveform with gtkwave. only works if companion vcd file is present, i.e. `tb_p8e0_mul.vcd`
gtkwave tb_p8e0_mul.gtkw
```


- run tests

```sh
pytest p8e0.py -v
```

---

(\*) on macOS this may not work natively. Follow this to enable gtkwave from CLI: https://gist.github.com/urbanij/ea2a4c355c1827ec9e52b5a3dfab9a74 or just open gtkwave like a normal application and then File -> Open New Tab -> pick the `.gktw` or `.vcd` file you need.



(\*\*) Note about `sv2v`

In order to overcome the limitation of Icarus Verilog which is unable to parse correctly some idiomatic features of SystemVerilog, such as packages (e.g. `import p8e0_pkg::*;`), I decided to temporarily use this nifty converter, https://github.com/zachjs/sv2v , which embeds the functions inside packages into the main _target_ module, therby allowing for a backward-compatibility with Verilog. This means that Icarus has now an easy time understanding the output of the conversion, and ultimately the turnaround time just dropped from minutes (compiling SV with Quartus/Vivado) to 2 seconds with this shortcut.
