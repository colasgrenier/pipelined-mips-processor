proc AddWaves {} {
	add wave -position end sim:/memory_testbench/clock
	add wave -position end sim:/memory_testbench/address
	add wave -position end sim:/memory_testbench/data
	add wave -position end sim:/memory_testbench/read
	add wave -position end sim:/memory_testbench/write
	add wave -position end sim:/memory_testbench/result
}

vlib work

vcom memory.vdh
vcom memory_testbench.vdh

vsim memory_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 10000ns
