# PPU

![img](ppu.svg)

---


## Build instructions

Check out [BUILD.md](./docs/BUILD.md) (might be outdated)

---

## Arch

The design is customizable in terms of Posit format (P<any, any>), operations supported (e.g. including/leaving out conversions) and internal implementations details (e.g. using LUT for division or adding newton-raphson steps) via macros and preprocessor `ifdef`s. 


# Get started

Generate single systemverilog file. Changing `$TOP` to any other module should work as well.
```sh
make TOP=ppu_top
```
