mul:
	python tb_gen.py --operation mul --shuffle-random true
	sv2v -DPROBE_SIGNALS -DTEST_BENCH p8e0_mul.sv p8e0_pkg.sv tb_p8e0_mul.sv > out.v
	iverilog out.v
	./a.out

	yosys -p "synth_intel -family max10 -top p8e0_mul -vqm p8e0_mul.vqm" out.v > yosys_intel.out
	./count_latch_inferred.py yosys_intel.out

add:
	python tb_gen.py --operation add --shuffle-random true
	sv2v -DTEST_BENCH p8e0_add.sv p8e0_pkg.sv tb_p8e0_add.sv > out.v
	iverilog out.v
	./a.out

	yosys -p "synth_intel -family max10 -top p8e0_add -vqm p8e0_add.vqm" out.v > yosys_intel.out
	./count_latch_inferred.py yosys_intel.out

clean:
	rm -rf *.out *.vcd *.vqm *.edif __pycache__ .pytest_cache 
	