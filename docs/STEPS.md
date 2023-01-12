Thu 12 Jan 2023 11:34:13 CET


From within `ppu` directory:

    export RISCV_PPU_ROOT=$(cd .. && pwd)

edit `Makefile_new.mk` and set your preferred posit size `N`, posit exponent `ES`, word width `WORD`, and the support for floating point `F` (F in {0, 16, 32})

    make -f Makefile_new.mk gen-test-vectors
  
    make -f Makefile_new.mk 
  