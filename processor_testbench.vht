library ieee;
use ieee.std_logic_1164.all;


entity processor_testbench is
end processor_testbench;

architecture tb of processor_testbench is
    signal clk, reset : std_logic;  -- inputs 
	 COMPONENT processor PORT (
        clock       : in std_logic;
        reset       : in std_logic
    );
	END COMPONENT;
begin

    --Generate the clock
    clock_process : PROCESS 
    begin
	    clk <= '0';
		 wait for 1 ns;
		 clk <= '1';
		 wait for 1 ns;
	 end process;

	 proc : processor PORT MAP (clock => clk, reset => reset);    
end tb;