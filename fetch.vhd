library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;


ENTITY fetch IS
	PORT (
		clock		: in std_logic;				-- clock signal.
		c_wait		: in std_logic;				-- whether to continue to the next address or not.
		branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0)	-- instruction that was read.
	);
END ENTITY;

ARCHITECTURE fetch_arch OF fetch IS
	TYPE instruction_memory_type		IS ARRAY (8095 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL instruction_memory_contents	: instruction_memory_type;
	SIGNAL program_counter			: std_logic_vector(31 downto 0);
	
BEGIN
process(clock)
	-- Initialize the memory.
	FILE instruction_memory_file		: TEXT;
	VARIABLE instruction_memory_line	: LINE;
	VARIABLE instruction_memory_data	: std_logic_vector(31 downto 0);
	
	begin
	  
	IF (now < 1ps) THEN
		file_open(instruction_memory_file, "instruction_memory.dat", READ_MODE);
		FOR line IN 0 TO 8095 LOOP
			readline(instruction_memory_file, instruction_memory_line);
			read(instruction_memory_line, instruction_memory_data);
			instruction_memory_contents(line) <= instruction_memory_data;
		END LOOP;
		file_close(instruction_memory_file);
	END IF;
	-- Execute the request.
	IF rising_edge(clock) THEN
		-- Put the requested content.
		instruction <= instruction_memory_contents(to_integer(unsigned(program_counter)));
		-- Check the signals
		IF c_wait = '1' THEN
			-- do nothing, as the decode stage has asked to wait.
		ELSE
			IF branch_taken = '1' THEN
				-- the ALU has computed that the branch must be taken.
				program_counter <= branch_address;
			ELSE
				-- no branching, increment the program counter by 4.
				program_counter <= program_counter + 4;
			END IF;
		END IF;
	END IF;
end process;
END fetch_arch;


