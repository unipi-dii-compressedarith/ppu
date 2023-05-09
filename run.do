global env

if [file exists "work"] {vdel -all}
vlib work

vlog a.sv

set TOP_LEVEL $env(TOP)

vsim ${TOP_LEVEL} -voptargs=+acc=npr

run -all
exit
