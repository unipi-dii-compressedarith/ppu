if [file exists "work"] {vdel -all}
vlib work

vlog a.sv

vsim tb_ppu -voptargs=+acc=npr

run -all
exit
