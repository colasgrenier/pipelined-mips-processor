ENTITY memory IS
	PORT (
		clock		: in std_logic;
		read		: in std_logic;				-- must read from data memory.
		write		: in std_logic;				-- must write to data memory.
		address		: in std_logic_vector(31 downto 0);
		write_data	: in std_logic_vector(31 downto 0);
		result		: out std_logic_vector(31 downto 0);
		target		: out std_logic_vector(4 downto 0);	-- target register for hazard detection / forwarding.
	);
END ENTITY;
	
ARCHITECTURE memory_arch OF memory IS	
BEGIN
	PROCESS (clock) BEGIN
		IF (rising_edge(clock)) THEN
			IF (memory_read = '1') THEN
				-- read from main memory then
				-- result <= memory value.
			ELSE IF (memory_write = '1') THEN
				-- write the vlaue to main memory.
			ELSE
				-- no read and no write, then the result is the read_data_2
				output <= read_data_2;
			END IF;
		END IF;
	END PROCESS;
END memory_arch;

ENTITY data_memory IS
	PORT (
		clock		: in std_logic;
		read		: in std_logic;
		write		: in std_logic;
		address		: in std_logic_vector(31 downto 0);
		input		: in std_logic_vector(31 downto 0);
		wait		: out std_logic;
		output		: out std_logic_vector(31 downto 0);
	);
END ENTITY;
