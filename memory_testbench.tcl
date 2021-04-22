proc AddWaves {} {
	add wave -position end sim:/memory_testbench/clock
	add wave -position end -hex sim:/memory_testbench/mtb_address
	add wave -position end -dec sim:/memory_testbench/mtb_data
	add wave -position end sim:/memory_testbench/mtb_read
	add wave -position end sim:/memory_testbench/mtb_write
	add wave -position end -dec sim:/memory_testbench/mtb_result
}

vlib work

vcom memory.vhd
vcom memory_testbench.vhd

vsim memory_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 10ns
