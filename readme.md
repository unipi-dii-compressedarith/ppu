# PPU

#### TODO:

- P<8,0>
    - [ ] add
    - [x] mul
    - [ ] div
    - [ ]

- P<16,0>
    - [ ] add
    - [ ] mul
    - [ ] div
    - [ ]


#### file org:
```
.
├── readme.md
│
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

|linux (*)             |macOS                        |                      |
|----------------------|-----------------------------|----------------------|
|`apt install gtkwave` |`brew install gtkwave`       |[1] (~5 MB)           |
|`apt install iverilog`|`brew install icarus-verilog`|[2] (~7 MB)           |
|`apt install yosys`   |`brew install yosys`         |[3] optional, (~33 MB)|


---
(*) prepend `sudo` if necessary

[1] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

[2] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog)

[3] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

