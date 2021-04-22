library ieee;
use ieee.std_logic_1164.all;


entity processor_testbench is
end processor_testbench;

ARCHITECTURE tb OF processor_testbench IS

	SIGNAL clock : std_logic;
	SIGNAL reset : std_logic; 

	CONSTANT clock_period	: time := 1 ns;

	COMPONENT processor PORT (
	        clock       : in std_logic;
	        reset       : in std_logic
	    );
	END COMPONENT;
begin

	proc : processor PORT MAP (clock => clock, reset => reset);    

	--Generate the clock
	clock_process : PROCESS 
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;

end tb;
