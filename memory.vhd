ENTITY memory IS
	PORT (
		clock		: in std_logic;
		address		: in std_logic_vector(31 downto 0);
		write_data	: in std_logic_vector(31 downto 0);
		read_data	: out std_logic_vector(31 downto 0);
		target		: out std_logic_vector(31 downto 0);	-- target register for hazard detection / forwarding.
	);
END ENTITY;

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
