mul:
	python tb_gen.py
	sv2v -DPROBE_SIGNALS  p8e0_mul.sv p8e0_pkg.sv tb_p8e0_mul.sv > out.v
	iverilog out.v
	./a.out

clean:
	rm -rf *.out *.vcd *.vqm __pycache__ .pytest_cache 