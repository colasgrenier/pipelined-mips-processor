library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all; 
use ieee.numeric_std.ALL;

ENTITY memory IS
	PORT (
		clock					: in std_logic;
		memory_read			: in std_logic;				-- must read from data memory.
		memory_write		: in std_logic;				-- must write to data memory.
		
		memory_use_memory 	: in std_logic; --Forwarding control
		memory_use_writeback : in std_logic; --Forwarding control
		writeback_data    	: in std_logic_vector(31 downto 0); --Forwarding data
		
		address				: in std_logic_vector(31 downto 0);
		write_data			: in std_logic_vector(31 downto 0);
		result				: out std_logic_vector(31 downto 0)
	);
END memory;
	
ARCHITECTURE memory_arch OF memory IS

	--data memory is 8192 words of 4 bytes (32,768 bytes)
	TYPE memory_type IS ARRAY(8191 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL memory_contents: memory_type;
	
	--Hold results after forwarding
	SIGNAL store_data : std_logic_vector(31 downto 0);
	SIGNAL inner_result : std_logic_vector(31 downto 0);
	
BEGIN

	store_data <= inner_result when memory_use_memory = '1' else
				     writeback_data when memory_use_writeback = '1' else
				     write_data;
	--permanent connection from inner_result to ouput result
	result <= inner_result;
					 
					 
	PROCESS (clock)
		FILE memory_file			: TEXT;
		VARIABLE memory_line 	: LINE;
		
		BEGIN
		
		-- initialise the memory.
		IF (NOW < 1 ps) THEN
			FOR addr IN 0 TO 8191 LOOP
				memory_contents(addr) <= x"00000000";
			END LOOP;
		END IF;
		
		
		-- actual memory process.
		IF (rising_edge(clock)) THEN
		
			--Initialize result
			inner_result <= x"00000000";
			
			IF (memory_read = '1') THEN
				-- read from main memory then
				-- result <= memory value.
				inner_result <= memory_contents(to_integer(unsigned(address(14 downto 2))));
			ELSIF (memory_write = '1') THEN
				-- write the vlaue to main memory.
				memory_contents(to_integer(unsigned(address(14 downto 2)))) <= store_data;
			ELSE
				-- no read and no write, then the result is the execute result.
				inner_result <= address;
			END IF;
			
			
		ELSIF (falling_edge(clock)) THEN
				-- dump to the memory file every falling edge of the clock signal.
				-- not efficient, but minimizes errors.
				file_open(memory_file, "memory.dat", WRITE_MODE);
				FOR line IN 0 TO 8191 LOOP
					write(memory_line, memory_contents(line));
					writeline(memory_file, memory_line);
				END LOOP;
				file_close(memory_file);
		END IF;
		
	END PROCESS;
END memory_arch;
