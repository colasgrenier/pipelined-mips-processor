proc AddWaves {} {
	add wave -position end sim:/fetch_testbench/clock
	add wave -position end sim:/fetch_testbench/ftb_stall
	add wave -position end sim:/fetch_testbench/ftb_branch_taken
	add wave -position end -hex sim:/fetch_testbench/ftb_branch_address
	add wave -position end -hex sim:/fetch_testbench/ftb_instruction
}

vlib work

vcom fetch.vhd
vcom fetch_testbench.vhd

vsim fetch_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 100ns
