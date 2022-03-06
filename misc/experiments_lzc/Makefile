.PHONY : pulp

gen_test_vector:
	python tb_gen_lzc.py > tv_lzc.sv

pulp: gen_test_vector
	sv2v -DTB_LZC lzc.sv cf_math_pkg.sv > lzc.v && iverilog lzc.v && ./a.out
	gtkwave tb_lzc_pulp.vcd &

ours: gen_test_vector
	sv2v -DN=16 -DTEST_BENCH_CLS ../../src/cls.sv ../../src/utils.sv ../../src/highest_set.sv > cls.v && \
	iverilog cls.v && ./a.out
	gtkwave tb_cls.gtkw &


ameetgohil: gen_test_vector
	sv2v -DN=32 -DTB ameetgohil.sv > ameetgohil.v
	iverilog ameetgohil.v && ./a.out

milenkovic: gen_test_vector
	python tb_gen_lzc.py > tv_lzc.sv
	sv2v -DTB_MILENKOVIC milenkovic.sv > milenkovic.v && iverilog milenkovic.v && ./a.out
	gtkwave tb_milenkovic.gtkw &

pacogen: gen_test_vector
	sv2v -DTB_PACOGEN lzc_pacogen.sv > lzc_pacogen.v
	iverilog lzc_pacogen.v
	./a.out
	gtkwave tb_pacogen.gtkw &

cls_vs_lzc:
    