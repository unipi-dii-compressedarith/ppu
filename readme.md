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
|
├── quartus
│   └── ...
└── src
    ├── p16e0
    │   ├── add.sv
    │   ├── convert.sv
    │   └── mul.sv
    └── p8e0
        ├── add.sv
        ├── convert.sv
        └── mul.sv
```


### cli tools

<details>
<summary>Install prerequisites</summary>


```sh
# use `brew` if macOS, `apt` if ubuntu

apt install gtkwave    # [1] (~5 MB)
apt install iverilog   # [2] (~7 MB)
apt install yosys      # [3] optional, (~33 MB)
```


[1] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)<br>
[2] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog) <br>
[3] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

</details>

---
