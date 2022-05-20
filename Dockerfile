FROM federicorossifr/ppuvhdl-env

ADD ./ /Sources/ppu
WORKDIR /Sources
ENV RISCV_PPU_DIR /Sources
WORKDIR /Sources/ppu
RUN make gen-test-vectors
RUN make ppu WORD=64 F=32 N=8 ES=0
