include Makefile_new.mk

compile: morty
	xvlog -sv a.sv
	# generates: webtalk.jou xsim.dir xvlog.log xvlog.pb

elaborate: compile
	xelab -debug typical --top $(TOP) -snapshot sim_$(TOP)
	# generates: webtalk.log

simulations: elaborate
	# xsim sim_$(TOP) -R
	xsim sim_$(TOP) --tclbatch xsim_cfg.tcl

view:
	xsim --gui sim_$(TOP).wdb

clean:
	rm -rf *.jou *.log xsim.dir
