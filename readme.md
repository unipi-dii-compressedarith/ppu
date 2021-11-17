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

<details>
    
<summary>Install prerequisites</summary>

`brew` if macOS, `apt` if ubuntu

```sh
apt install gtkwave # (~5 MB)
apt install iverilog   # (~7 MB)
apt install yosys   # optional, (~33 MB)
```

</details>


```sh
pytest p8mul.py
```

