mul:
	python tb_gen.py --operation mul # --shuffle-random true
	sv2v -DPROBE_SIGNALS p8e0_mul.sv p8e0_pkg.sv tb_p8e0_mul.sv > out.v
	iverilog out.v
	./a.out

add:
	python tb_gen.py --operation add
	sv2v p8e0_add.sv p8e0_pkg.sv tb_p8e0_add.sv > out.v
	iverilog out.v
	./a.out

clean:
	rm -rf *.out *.vcd *.vqm *.edif __pycache__ .pytest_cache 
	