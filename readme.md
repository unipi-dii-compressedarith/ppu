# PPU





#### file org:
```
!todo
```


#### known bugs:

- [ ] fails at interpreting `posit8(bits = 0x81)` -> use a wider size for k ($clog2(N) + 2?)




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

