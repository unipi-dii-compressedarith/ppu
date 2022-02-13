# PPU




### usage:

- install prerequisites:
    
    - [cli tools](#cli_tools)
    - [`hardposit`](https://github.com/urbanij/hardposit) (dependency of [`scripts/tb_gen.py`](./scripts/tb_gen.py)).

- generate all the waveforms

```sh
make 
```



### known bugs:





### cli tools

|   |linux (*)             |macOS                        |                |
|---|----------------------|-----------------------------|----------------|
|[1]|`apt install gtkwave` |`brew install gtkwave`       |~5 MB           |
|[2]|`apt install iverilog`|`brew install icarus-verilog`|~7 MB           |
|[3]|`apt install yosys`   |`brew install yosys`         |optional, ~33 MB|


---
(*) prepend `sudo` if necessary

[1] [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

[2] [https://github.com/steveicarus/iverilog](https://github.com/steveicarus/iverilog)

[3] [https://github.com/YosysHQ/yosys](https://github.com/YosysHQ/yosys)

