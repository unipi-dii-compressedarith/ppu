# PPU

#### TODO:

- P<16,0>
    - [ ] add
    - [ ] mul
    - [ ] div
    - [ ]

- P<8,0>
    - [ ] add
    - [x] mul
    - [ ] div
    - [ ]


#### file org:
```
.
├── readme.md
│
├── quartus
│   └── ...
└── src
    ├── p16e0
    │   ├── p16e0_add.sv
    │   ├── convert.sv
    │   └── p16e0_mul.sv
    └── p8e0
        ├── p8e0_add.sv
        ├── convert.sv
        └── p8e0_mul.sv
```


### cli tools

<details>
<summary>Install prerequisites</summary>


```sh
# use `brew` if macOS, `apt` if ubuntu

apt install gtkwave    # [1] (~5 MB)
apt install iverilog   # [2] (~7 MB) use "brew install icarus-verilog" on macOs
apt install yosys      # [3] optional, (~33 MB)
```


[1] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)<br>
[2] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog) <br>
[3] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

</details>

---
