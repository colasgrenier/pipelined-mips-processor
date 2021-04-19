library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

ENTITY fetch IS
	PORT (
		clock		: in std_logic;				-- clock signal.
		stall		: in std_logic;				-- whether to continue to the next address or not.
		branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0);	-- instruction that was read.
		program_counter : out std_logic_vector(31 downto 0)
	);
END ENTITY;

ARCHITECTURE fetch_arch OF fetch IS
	
	TYPE   instruction_memory_type		IS ARRAY (8195 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL instruction_memory_contents	: instruction_memory_type;
	SIGNAL address				: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL instruction_buffer		: std_logic_vector(31 downto 0);

BEGIN

	program_counter <= address;
	instruction <= instruction_buffer;



process(clock)

	FILE instruction_memory_file		: TEXT;
	VARIABLE instruction_memory_line	: LINE;
	VARIABLE instruction_memory_data	: std_logic_vector(31 downto 0);
	VARIABLE line				: integer;
	VARIABLE initialized			: boolean;
	VARIABLE stall_counter			: integer := 0;
	VARIABLE temp				: std_logic_vector(31 downto 0);

BEGIN
	IF (now < 1 ps AND NOT initialized) THEN
		initialized := true;
		REPORT "initializing instruction memory...";
		instruction_buffer <= x"00000000";
		-- Initialize everyting to 0, in case the program does not contain 8196 words.
		FOR line IN 0 to 8195 LOOP
			REPORT "    " & integer'image(line);
			instruction_memory_contents(line) <= x"00000000";
		END LOOP;
		-- Fill the memory with the contents of the line.
		file_open(instruction_memory_file, "program.txt", READ_MODE);
		line := 0;
		WHILE NOT endfile(instruction_memory_file) LOOP
			REPORT "    file read " & integer'image(line);
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
		REPORT "fetch: rising edge";
		-- Check the signals
		IF stall = '1' THEN
			-- do nothing, as the decode stage has asked to wait.
		ELSE
			IF stall_counter > 0 THEN
				REPORT "fetch: stalling";
				stall_counter := stall_counter - 1;
			ELSE
				-- The last instruction was not a branch or jump, we output the next instruction normally.
				REPORT "fetch: no stalling here " & integer'image(to_integer(unsigned(address)));
				IF branch_taken = '1' THEN
					-- the ALU has computed that the branch must be taken.
					address <= branch_address + 4;
					-- Put the instruction at the next program counter.
					instruction_buffer <= instruction_memory_contents(to_integer(unsigned(branch_address(31 downto 2))));
					temp := instruction_memory_contents(to_integer(unsigned(branch_address(31 downto 2))));
					IF (temp(31 downto 26) = "000000") AND (temp(5 downto 0) & "00" = x"08") THEN
						-- The last instruction was a jr instruction, we insert two nops.
						REPORT "fetch: last instruction was JR, insert two nops";
						stall_counter := 1;
						instruction_buffer <= x"00000000";
					ELSIF (temp(31 downto 26) & "00" = x"02") OR (temp(31 downto 26) & "00" = x"03") OR (temp(31 downto 26) & "00" = x"04") OR (temp(31 downto 26) & "00" = x"05") THEN
						-- The last instruction was beq/bne/j/jal, we insert two nops.
						REPORT "fetch: last instruction was BEQ/BNE/J/JAL, insert two nops";
						stall_counter := 1;
						instruction_buffer <= x"00000000";
					END IF;
				ELSE
					-- Put the current instruction.
					instruction_buffer <= instruction_memory_contents(to_integer(unsigned(address(31 downto 2))));
					temp := instruction_memory_contents(to_integer(unsigned(address(31 downto 2))));
					-- No branching, increment the program counter by 4.
					address <= address + 4;
					IF (temp(31 downto 26) = "000000") AND (temp(5 downto 0) & "00" = x"08") THEN
						-- The last instruction was a jr instruction, we insert two nops.
						REPORT "fetch: last instruction was JR, insert two nops";
						stall_counter := 1;
						instruction_buffer <= x"00000000";
					ELSIF (temp(31 downto 26) & "00" = x"02") OR (temp(31 downto 26) & "00" = x"03") OR (temp(31 downto 26) & "00" = x"04") OR (temp(31 downto 26) & "00" = x"05") THEN
						-- The last instruction was beq/bne/j/jal, we insert two nops.
						REPORT "fetch: last instruction was BEQ/BNE/J/JAL, insert two nops";
						stall_counter := 1;
						instruction_buffer <= x"00000000";
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
end process;
END fetch_arch;
