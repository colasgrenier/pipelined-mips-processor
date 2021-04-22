proc AddWaves {} {
	add wave -position end sim:/processor_testbench/clock
	add wave -position end -hex sim:/processor_testbench/proc/decode_stage/instruction
	add wave -position end sim:/processor_testbench/proc/decode_stage/stall_fetch
	add wave -position end sim:/processor_testbench/proc/decode_stage/execute_result_available_execute
	add wave -position end -dec sim:/processor_testbench/proc/decode_stage/execute_target
	add wave -position end -dec sim:/processor_testbench/proc/decode_stage/memory_target
	add wave -position end -dec sim:/processor_testbench/proc/decode_stage/writeback_target
	add wave -position end -hex sim:/processor_testbench/proc/execute_stage/opcode
	add wave -position end -hex sim:/processor_testbench/proc/execute_stage/funct
	add wave -position end sim:/processor_testbench/proc/execute_stage/execute_1_use_execute
	add wave -position end sim:/processor_testbench/proc/execute_stage/execute_2_use_execute
	add wave -position end sim:/processor_testbench/proc/execute_stage/execute_1_use_memory
	add wave -position end sim:/processor_testbench/proc/execute_stage/execute_2_use_memory
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/read_data_1
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/read_data_2
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/immediate
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/result
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/branch_address
	add wave -position end -dec sim:/processor_testbench/proc/execute_stage/branch_taken
	add wave -position end sim:/processor_testbench/proc/memory_stage/memory_read
	add wave -position end sim:/processor_testbench/proc/memory_stage/memory_write
	add wave -position end sim:/processor_testbench/proc/memory_stage/memory_use_memory
	add wave -position end -dec sim:/processor_testbench/proc/memory_stage/address
	add wave -position end -dec sim:/processor_testbench/proc/memory_stage/write_data
	add wave -position end -dec sim:/processor_testbench/proc/memory_stage/result
	

}

vlib work

vcom fetch.vhd
vcom decode.vhd
vcom execute.vhd
vcom memory.vhd
vcom processor.vhd
vcom processor_testbench.vht

vsim processor_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 100ns

wave zoom full
