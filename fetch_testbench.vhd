library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY fetch_testbench IS
END ENTITY;

ARCHITECTURE behavioural OF fetch_testbench IS
	
	COMPONENT fetch IS
		PORT (
			clock		: in std_logic;				-- clock signal.
			stall		: in std_logic;				-- whether to continue to the next address or not.
			branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
			branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
			instruction	: out std_logic_vector(31 downto 0)	-- instruction that was read.
		);
	END COMPONENT;

	-- Test signals.
	SIGNAL reset		: std_logic := '0';
	SIGNAL clock		: std_logic := '0';
	CONSTANT clock_period	: time := 1 ns;

	-- Interconnects.
	SIGNAL ftb_stall		: std_logic := '0';
	SIGNAL ftb_branch_taken		: std_logic := '0';
	SIGNAL ftb_branch_address	: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL ftb_instruction		: std_logic_vector(31 downto 0);

BEGIN
	
	FET: fetch
	port map(
		clock => clock,
		stall => ftb_stall,
		branch_taken => ftb_branch_taken,
		branch_address => ftb_branch_address,
		instruction => ftb_instruction
	);
	
	clock_process: PROCESS BEGIN
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	END PROCESS;
	
	test_process: PROCESS BEGIN
		
		-- Initialize
		WAIT FOR 1*clock_period;

		-- Test stalling.
		WAIT FOR 4*clock_period;
		WAIT FOR 1/2*clock_period;
		ftb_stall <= '1';
		WAIT FOR 1*clock_period;
		ftb_stall <= '0';
		WAIT FOR 1/2*clock_period;

		-- Test branching.
		WAIT FOR 3*clock_period;
		ftb_branch_address <= x"00000000";
		ftb_branch_taken <= '1';
		WAIT FOR 1*clock_period;
		ftb_branch_taken <= '0';
		
		WAIT;

	END PROCESS;
			
END;
