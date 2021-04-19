proc AddWaves {} {
	add wave -position end sim:/decode_testbench/clock
	add wave -position end -hex sim:/decode_testbench/dtb_instruction
	add wave -position end sim:/decode_testbench/dtb_stall
	# add wave -position end -hex sim:/decode_testbench/dtb_branch_address
	# add wave -position end sim:/decode_testbench/dtb_branch_taken
	add wave -position end sim:/decode_testbench/DEC/stalling
	add wave -position end -dec sim:/decode_testbench/DEC/execute_target
	add wave -position end -dec sim:/decode_testbench/DEC/memory_target
	add wave -position end -dec sim:/decode_testbench/DEC/writeback_target
	add wave -position end -hex sim:/decode_testbench/dtb_opcode
	add wave -position end -hex sim:/decode_testbench/dtb_funct
	add wave -position end -dec sim:/decode_testbench/dtb_read_data_1
	add wave -position end -dec sim:/decode_testbench/dtb_read_data_2
	add wave -position end -dec sim:/decode_testbench/dtb_immediate
	add wave -position end sim:/decode_testbench/dtb_execute_1_use_execute
	add wave -position end sim:/decode_testbench/dtb_execute_2_use_execute
	add wave -position end sim:/decode_testbench/dtb_execute_1_use_memory
	add wave -position end sim:/decode_testbench/dtb_execute_2_use_memory
	add wave -position end sim:/decode_testbench/dtb_memory_use_memory
}

vlib work

vcom fetch.vhd
vcom decode.vhd
vcom decode_testbench.vhd

vsim decode_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 25ns

wave zoom full
