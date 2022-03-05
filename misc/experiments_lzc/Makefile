.PHONY : pulp

pulp:
	sv2v -DTB_LZC lzc.sv cf_math_pkg.sv > lzc.v && iverilog lzc.v && ./a.out
	gtkwave tb_lzc_pulp.vcd &

ours:
	sv2v -DN=16 -DTEST_BENCH_CLS ../../src/cls.sv ../../src/utils.sv ../../src/highest_set.sv > cls.v && \
	iverilog cls.v && ./a.out
	gtkwave tb_cls.gtkw &


ameetgohil:
	sv2v -DN=32 -DTB ameetgohil.sv > ameetgohil.v
	iverilog ameetgohil.v && ./a.out

milankovic:
	python tb_gen_lzc.py > tv_lzc.sv
	sv2v -DTB_MILANKOVIC milankovic.sv > milankovic.v && iverilog milankovic.v && ./a.out
	gtkwave tb_milankovic.gtkw &

pacogen:
	sv2v lzc_pacogen.sv > lzc_pacogen.v

cls_vs_lzc:
    