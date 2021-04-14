proc AddWaves {} {
	add wave -position end sim:/execute_testbench/clock
	add wave -position end sim:/execute_testbench/etb_opcode
	add wave -position end sim:/execute_testbench/etb_shamt
	add wave -position end sim:/execute_testbench/etb_funct
	add wave -position end sim:/execute_testbench/etb_rd_1
	add wave -position end sim:/execute_testbench/etb_rd_2
	add wave -position end sim:/execute_testbench/etb_immediate
    add wave -position end sim:/execute_testbench/etb_target
    add wave -position end sim:/execute_testbench/etb_pc
    add wave -position end sim:/execute_testbench/etb_result
    add wave -position end sim:/execute_testbench/etb_pc_out
    add wave -position end sim:/execute_testbench/etb_branch_taken
    add wave -position end sim:/execute_testbench/etb_next_target
}

vlib work

vcom execute.vhd
vcom execute_testbench.vhd

vsim execute_testbench

force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1ns

AddWaves

run 100ns
