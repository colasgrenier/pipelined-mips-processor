library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY memory_testbench IS
END ENTITY;

ARCHITECTURE behavioural OF memory_testbench IS
	
	COMPONENT memory IS
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
	END COMPONENT;

	-- Test signals.
	SIGNAL reset		: std_logic := '0';
	SIGNAL clock		: std_logic := '0';
	CONSTANT clock_period	: time := 1 ns;

	-- Interconnects.
	SIGNAL mtb_read		: std_logic := '0';
	SIGNAL mtb_write	: std_logic := '0';
	SIGNAL mtb_address	: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL mtb_data		: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL mtb_result	: std_logic_vector(31 downto 0);
	SIGNAL mtb_next_target	: std_logic_vector(4 downto 0) := "00000";

BEGIN
	
	MEM: memory
	port map(
		clock => clock,
		memory_read => mtb_read,
		memory_write => mtb_write,
		address => mtb_address,
		write_data => mtb_data,
		result => mtb_result,
		next_target => mtb_next_target
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
		
		-- Write to an address.
		mtb_address <= x"00000000";
		mtb_data <= x"12341234";
		mtb_write <= '1';
		WAIT FOR 1*clock_period;
		mtb_write <= '0';
		mtb_read <= '1';
		WAIT FOR 1*clock_period;
		ASSERT mtb_result = X"12341234" REPORT "error writing then reading 12341234 to address x00000000" SEVERITY FAILURE;
		mtb_read <= '0';

		-- Write to another address
		mtb_address <= x"00000010";
		mtb_data <= x"67896789";
		mtb_write <= '1';
		WAIT FOR 1*clock_period;
		mtb_write <= '0';
		mtb_read <= '1';
		WAIT FOR 1*clock_period;
		ASSERT mtb_result = x"67896789" REPORT "error writing then reading 67896789 to 0x00000010" SEVERITY FAILURE;
		mtb_read <= '0';

		-- Try to read the first write.
		mtb_address <= x"00000000";
		mtb_read <= '1';
		WAIT FOR 1*clock_period;
		ASSERT mtb_result = x"12341234" REPORt "failed to read initial write of 12341234 to 0x0" SEVERITY FAILURE;
	END PROCESS;
			
END;
