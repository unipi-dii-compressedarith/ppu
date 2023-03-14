if [file exists "work"] {vdel -all}
vlib work

vlog a.sv

vsim tb_fma -voptargs=+acc=npr

run -all
exit
