library STD;
use STD.textio.all;
library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_textio.all; 

ENTITY memory IS
	PORT (
		clock				: in std_logic;
		next_target			: in std_logic;
		read				: in std_logic;				-- must read from data memory.
		write				: in std_logic;				-- must write to data memory.
		address				: in std_logic_vector(31 downto 0);
		data			: in std_logic_vector(31 downto 0);
		result				: out std_logic_vector(31 downto 0);
		result_available	: out std_logic;
		target				: out std_logic_vector(4 downto 0);	-- target register for hazard detection / forwarding.
	);
END ENTITY;
	
ARCHITECTURE memory_arch OF memory IS
	TYPE memory_type IS ARRAY(8095 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL memory_contents: memory_type;
BEGIN
	PROCESS (clock)
		FILE memory_file			: TEXT;
		VARIABLE memory_line : STRING (31 DOWNTO 0);
		BEGIN
		-- initialise the memory.
		IF (NOW < 1ps) THEN
			FOR addr IN 0 TO 8095 LOOP
				memory_contents <= x"00000000";
			END LOOP;
		END IF;
		-- actual memory process.
		IF (rising_edge(clock)) THEN
			IF (memory_read = '1') THEN
				-- read from main memory then
				-- result <= memory value.
				result <= memory_contents(to_integer(unsigned(address(12 downto 2))));
				result_available <= '1';
				target <= next_target;
			ELSE IF (memory_write = '1') THEN
				-- write the vlaue to main memory.
				memory_contents(to_integer(unsigned(address(12 downto 2)))) <= data;
				-- dump to the memory file
				file_open(memory_file, "memory.dat", WRITE_MODE);
				FOR line IN 0 TO 8095 LOOP
					write(memory_line, memory_contents(to_integer(unsigned(address(12 downto 2)))));
					writeline(memory_file, memory_line);
				END LOOP;
				file_close(memory_file);
				target <= next_target;
				result <= x"00000000";
				result_available <= '0';
			ELSE
				-- no read and no write, then the result is the read_data_2
				IF (next_target \= "00000") THEN
					output <= read_data_2;
					target <= next_target;
					result <= data;
					result_available <= '1';
				ELSE
					target <= "00000";
					result <= x"00000000";
					result_available <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END memory_arch;

