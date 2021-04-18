library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;


ENTITY fetch IS
	PORT (
		clock		: in std_logic;				-- clock signal.
		stall		: in std_logic;				-- whether to continue to the next address or not.
		branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0);	-- instruction that was read.
		program_counter_out : out std_logic_vector(31 downto 0)
	);
END ENTITY;

ARCHITECTURE fetch_arch OF fetch IS
	TYPE instruction_memory_type		IS ARRAY (8195 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL instruction_memory_contents	: instruction_memory_type;
	SIGNAL program_counter			: std_logic_vector(31 downto 0) := x"00000000";
	
BEGIN
program_counter_out <= program_counter;
process(clock)
	-- Initialize the memory.
	FILE instruction_memory_file		: TEXT;
	VARIABLE instruction_memory_line	: LINE;
	VARIABLE instruction_memory_data	: std_logic_vector(31 downto 0);
	VARIABLE line				: integer;
	begin
	  
	IF (now < 1 ps) THEN
		REPORT "initializing instruction memory...";
		instruction <= x"00000000";
		-- Initialize everyting to 0, in case the program does not contain 8196 words.
		FOR line IN 0 to 8195 LOOP
			instruction_memory_contents(line) <= x"00000000";
		END LOOP;
		-- Fill the memory with the contents of the line.
		file_open(instruction_memory_file, "program.txt", READ_MODE);
		line := 0;
		WHILE NOT endfile(instruction_memory_file) LOOP
			readline(instruction_memory_file, instruction_memory_line);
			read(instruction_memory_line, instruction_memory_data);
			instruction_memory_contents(line) <= instruction_memory_data;
			line := line + 1;
		END LOOP;
		file_close(instruction_memory_file);
		REPORT "instruction memory initialization complete";
	END IF;
	-- Execute the request.
	IF rising_edge(clock) THEN
		-- Check the signals
		IF stall = '1' THEN
			-- do nothing, as the decode stage has asked to wait.
		ELSE
			IF branch_taken = '1' THEN
				-- the ALU has computed that the branch must be taken.
				program_counter <= branch_address + 4;
				-- Put the instruction at the next program counter.
				instruction <= instruction_memory_contents(to_integer(unsigned(branch_address(31 downto 2))));
			ELSE
				-- Put the current instruction.
				instruction <= instruction_memory_contents(to_integer(unsigned(program_counter(31 downto 2))));
				-- No branching, increment the program counter by 4.
				program_counter <= program_counter + 4;
			END IF;
		END IF;
		
	END IF;
end process;
END fetch_arch;
