all: docs


N ?= 16
ES ?= 1
WORD ?= 32
F ?= 32
CLK_FREQ ?= 100



MORTY_ARGS :=                                     \
  -DN=$(N)                                        \
  -DES=$(ES)                                      \
  -DWORD=$(WORD)                                  \
                                                  \
  -DF=$(F)                                        \
                                                  \
  -DFX_M=$(31)                                  \
  -DFX_B=$(64)                                  \
                                                  \
  -DCLK_FREQ=$(CLK_FREQ)                          \
  -DPIPELINE_DEPTH=$(0)              \
  -DINNER_PIPELINE_DEPTH=$(0)  \

TOP ?= ppu_top
DOCS ?= ./docs/ppu-docs


bender:
	bender sources --flatten --target test > sources.json

docs: bender
	morty -f sources.json $(MORTY_ARGS) --top $(TOP) --doc $(DOCS)
	open $(DOCS)/index.html
