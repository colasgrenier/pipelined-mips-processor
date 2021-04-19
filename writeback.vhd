library ieee;
use ieee.std_logic_1164.all;

ENTITY writeback IS
	PORT (
		clock		: in std_logic;
		input		: in std_logic_vector(31 downto 0);
		result		: out std_logic_vector(31 downto 0)
	);
END ENTITY;
	
ARCHITECTURE writeback_arch OF writeback IS BEGIN
	PROCESS (clock) BEGIN
		IF rising_edge(clock) THEN
			REPORT "writeback: processing";
			result <= input;
		END IF;
	END PROCESS;
END writeback_arch;
