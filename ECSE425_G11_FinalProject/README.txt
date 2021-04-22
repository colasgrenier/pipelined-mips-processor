To run a program, simply place it in this level, alongside the rest of the VHDL components.
In Modelsim, change the directory to this file and run the command "source processor_testbench.tcl". 
It will automatically run the program for 100 ns (clock cycles) and display various signals over
the program's operation. Two files will be generated holding outputs, register_file.txt and memory.txt.

To extend the run length, open processor_testbench.tcl and change "run 100ns" to "run XXns", XX being
the duration you wish to run the program for.