library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all; 
use ieee.numeric_std.ALL;

ENTITY memory IS
	PORT (
		clock				: in std_logic;
		next_target			: in std_logic_vector(4 downto 0);
		memory_read			: in std_logic;				-- must read from data memory.
		memory_write			: in std_logic;				-- must write to data memory.
		address				: in std_logic_vector(31 downto 0);
		write_data			: in std_logic_vector(31 downto 0);
		result				: out std_logic_vector(31 downto 0);
		result_available		: out std_logic;
		target				: out std_logic_vector(4 downto 0)	-- target register for hazard detection / forwarding.
	);
END memory;
	
ARCHITECTURE memory_arch OF memory IS
	TYPE memory_type IS ARRAY(8195 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL memory_contents: memory_type;
BEGIN
	PROCESS (clock)
		FILE memory_file			: TEXT;
		VARIABLE memory_line 			: LINE;
		BEGIN
		-- initialise the memory.
		IF (NOW < 1 ps) THEN
			FOR addr IN 0 TO 8095 LOOP
				memory_contents(addr) <= x"00000000";
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
			ELSIF (memory_write = '1') THEN
				-- write the vlaue to main memory.
				memory_contents(to_integer(unsigned(address(12 downto 2)))) <= write_data;
				target <= next_target;
				result <= x"00000000";
				result_available <= '0';
			ELSE
				-- no read and no write, then the result is the input write data.
				IF next_target /= "00000" THEN
					target <= next_target;
					result <= write_data;
					result_available <= '1';
				ELSE
					target <= "00000";
					result <= x"00000000";
					result_available <= '0';
				END IF;
			END IF;
		ELSIF (falling_edge(clock)) THEN
				-- dump to the memory file every falling edge of the clock signal.
				-- not efficient, but minimizes errors.
				file_open(memory_file, "memory.dat", WRITE_MODE);
				FOR line IN 0 TO 8195 LOOP
					write(memory_line, memory_contents(line));
					writeline(memory_file, memory_line);
				END LOOP;
				file_close(memory_file);
		END IF;
	END PROCESS;
END memory_arch;
