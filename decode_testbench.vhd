library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY decode_testbench IS
END ENTITY;

ARCHITECTURE behavioural OF decode_testbench IS
	
	COMPONENT fetch IS
		PORT (
			clock		: in std_logic;				-- clock signal.
			stall		: in std_logic;				-- whether to continue to the next address or not.
			branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
			branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
			instruction	: out std_logic_vector(31 downto 0)	-- instruction that was read.
		);
	END COMPONENT;

	COMPONENT decode IS
	PORT (
		clock				: in std_logic;
		instruction			: in std_logic_vector(31 downto 0);
		write_data			: in std_logic_vector(31 downto 0);
		stall_fetch			: out std_logic;
		read_data_1			: out std_logic_vector(31 downto 0);
		read_data_2			: out std_logic_vector(31 downto 0);
		immediate			: out std_logic_vector(31 downto 0);
		opcode				: out std_logic_vector(5 downto 0);
		funct				: out std_logic_vector(5 downto 0);
		shamt				: out std_logic_vector(4 downto 0);
		memory_read			: out std_logic;
		memory_write			: out std_logic;
		execute_1_use_execute		: out std_logic;
		execute_2_use_execute		: out std_logic;
		execute_1_use_memory		: out std_logic;
		execute_2_use_memory		: out std_logic;
		memory_use_memory		: out std_logic;
		memory_use_writeback		: out std_logic
	);
	END COMPONENT;

	-- Test signals.
	SIGNAL reset		: std_logic := '0';
	SIGNAL clock		: std_logic := '0';
	CONSTANT clock_period	: time := 1 ns;

	-- Interconnects.
	SIGNAL dtb_stall		: std_logic := '1';
	SIGNAL dtb_instruction		: std_logic_vector(31 downto 0); 	-- instruction from fetch
	SIGNAL dtb_branch_address	: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL dtb_branch_taken		: std_logic := '0';
	SIGNAL dtb_write_data		: std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL dtb_rd1			: std_logic_vector(31 downto 0);
	SIGNAL dtb_rd2			: std_logic_vector(31 downto 0);
	SIGNAL dtb_immediate			: std_logic_vector(31 downto 0);
	SIGNAL dtb_opcode		: std_logic_vector(5 downto 0);
	SIGNAL dtb_funct		: std_logic_vector(5 downto 0);
	SIGNAL dtb_shamt		: std_logic_vector(4 downto 0);
	SIGNAL dtb_read_data_1		: std_logic_vector(31 downto 0);
	SIGNAL dtb_read_data_2		: std_logic_vector(31 downto 0);
	SIGNAL dtb_execute_1_use_execute	: std_logic;
	SIGNAL dtb_execute_2_use_execute	: std_logic;
	SIGNAL dtb_execute_1_use_memory	: std_logic;
	SIGNAL dtb_execute_2_use_memory	: std_logic;
	SIGNAL dtb_memory_use_memory	: std_logic;
	SIGNAL dtb_memory_read		: std_logic;
	SIGNAL dtb_memory_write		: std_logic;
BEGIN
	
	FET: fetch
	port map(
		clock => clock,
		stall => dtb_stall,
		branch_taken => dtb_branch_taken,
		branch_address => dtb_branch_address,
		instruction => dtb_instruction
	);

	DEC: decode
	port map(
		clock => clock,
		instruction => dtb_instruction,
		write_data => dtb_write_data,
		opcode => dtb_opcode,
		funct => dtb_funct,
		shamt => dtb_shamt,
		read_data_1 => dtb_read_data_1,
		read_data_2 => dtb_read_data_2,
		immediate => dtb_immediate,
		execute_1_use_execute => dtb_execute_1_use_execute,
		execute_2_use_execute => dtb_execute_2_use_execute,
		execute_1_use_memory => dtb_execute_1_use_memory,
		execute_2_use_memory => dtb_execute_2_use_memory,
		memory_use_memory => dtb_memory_use_memory,
		memory_read => dtb_memory_read,
		memory_write => dtb_memory_write
	);

	clock_process: PROCESS BEGIN
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	END PROCESS;
	
	test_process: PROCESS BEGIN
		
		WAIT FOR 1*clock_period;
		dtb_stall <= '0';
		WAIT;

	END PROCESS;
			
END;
