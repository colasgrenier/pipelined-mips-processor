library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY processor IS
    PORT (
        clock       : in std_logic;
        reset       : in std_logic;
    );
END ENTITY;

ARCHITECTURE processor_arch OF processor IS
	------------------Component declarations (ew)------------------
	COMPONENT fetch PORT (
		clock		: in std_logic;
		stall		: in std_logic;				-- whether to continue to the next address or not.
		branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0)	-- instruction that was read.
	);
	END COMPONENT;
	
	COMPONENT decode PORT (
		clock				: in std_logic;
		instruction			: in std_logic_vector(31 downto 0); --Instruction
		execute_result			: in std_logic_vector(31 downto 0);
		execute_result_available	: in std_logic;
		execute_target			: in std_logic_vector(4 downto 0);
		memory_result			: in std_logic_vector(31 downto 0);
		memory_result_available		: in std_logic;
		memory_target			: in std_logic_vector(4 downto 0);
		read_data_1			: out std_logic_vector(31 downto 0); 
		read_data_2			: out std_logic_vector(31 downto 0);
		immediate			: out std_logic_vector(31 downto 0);
		opcode				: out std_logic_vector(5 downto 0);
		funct				: out std_logic_vector();
		shamt				: out std_logic_vector();
		target 				: out std_logic_vector(4 downto 0);
		read				: out std_logic;
		write				: out std_logic;
		use_execute_result		: out std_logic;
		use_memory_result		: out std_logic;
	);
	END COMPONENT;
	
	COMPONENT execute PORT (
	   clock     			: in std_logic;
		opcode	   		: in std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
		shamt					: in std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
		funct					: in std_logic_vector(7 downto 0);    -- function (given by the decode stage)
		read_data_1			: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_2			: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate			: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		
		
		execute_1_use_execute 		: in std_logic; --control use execute result in port 1
		execute_2_use_execute		: in std_logic; --control use execute result in port 2
		execute_1_use_memory			: in std_logic; --control use mem result in port 1
		execute_2_use_memory			: in std_logic; --control use mem result in port 2
		memory_result					: in std_logic_vector(31 downto 0); --result of mem stage (for forwarding)
		
		next_target			: in std_logic_vector(4 downto 0);    -- the target register of the next instruction.
		program_counter	: in std_logic_vector(31 downto 0);   -- next instruction address.
		
		result				: out std_logic_vector(31 downto 0);  -- result of the ALU operation. (Inout for forwarding)
		branch_address		: out std_logic_vector(31 downto 0);  -- computed PC address.
		branch_taken		: out std_logic;					  		  -- indicated whether the branch has been taken.
		target				: out std_logic_vector(4 downto 0)    -- the target register of the current phase
    );
	END COMPONENT;
	
	COMPONENT memory PORT (
		clock				: in std_logic;
		next_target			: in std_logic_vector(4 downto 0);
		memory_read			: in std_logic;				-- must read from data memory.
		memory_write		: in std_logic;				-- must write to data memory.
		address				: in std_logic_vector(31 downto 0);
		write_data			: in std_logic_vector(31 downto 0);
		result				: out std_logic_vector(31 downto 0);
		result_available		: out std_logic;
		target				: out std_logic_vector(4 downto 0)	-- target register for hazard detection / forwarding.
	);
	END COMPONENT;
	
	------------------Interconnection Signals------------------
	
	--int appended to internal signals
	SIGNAL branch_taken_int : std_logic;
	SIGNAL branch_address_int	: std_logic_vector(31 downto 0);	-- computed address for branch.
	SIGNAL instruction_int	: std_logic_vector(31 downto 0);	-- instruction
	
	SIGNAL opcode_int	: std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
	SIGNAL shamt_int	: std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
	SIGNAL funct_int	: std_logic_vector(7 downto 0);    -- function (given by the decode stage)
	SIGNAL read_data_1_int	: std_logic_vector(31 downto 0);   -- data from register file.
	SIGNAL read_data_2_int	: std_logic_vector(31 downto 0);   -- data from register file.
	SIGNAL immediate_int		: std_logic_vector(31 downto 0);   -- immediate value from instruction.
	
	
	--SIGNAL execute_1_use_execute_int, execute_2_use_execute_int,
	--		 execute_1_use_memory_int, execute_2_use_memory_int : std_logic; --forwarding control
	
	--SIGNAL program_counter_int	: std_logic_vector(31 downto 0);   -- next instruction address.
	
	SIGNAL memory_result_int		: std_logic_vector(31 downto 0); --result of mem stage (for forwarding)
	SIGNAL execute_result_int	: std_logic_vector(31 downto 0);  -- result of the ALU operation.
	
	SIGNAL decode_target_int	: std_logic_vector(4 downto 0); 
	SIGNAL execute_target_int	: std_logic_vector(4 downto 0);
	SIGNAL memory_target_int	: std_logic_vector(4 downto 0);
	
	--These signals are buffered by 1
	--for execute to run before memory
	SIGNAL memory_read_int1, memory_write_int1,
			 memory_read_int2, memory_write_int2: std_logic;
	SIGNAL memory_write_data_int : std_logic_vector(31 downto 0);
	
	--TO IMPLEMENT (signals need ports):
	--stall (out from dec), forwarding control (what's happening honestly),
	--program counter (out from fetch)
	
BEGIN
	------------------ Instantiations ------------------
	fetchStage : fetch PORT MAP ( 
						clock => clock, 
						stall => ???,
						branch_taken => branch_taken_int,
						branch_address => branch_address_int,
						instruction => instruction_int);
						
	--I'm going to leave this, the interface seems unfinished
	decodeStage : decode PORT MAP ( 
						clock => clock, 
						instruction => instruction_int,
						execute_result	=> execute_result_int, --Oh I see why this is here, we need to rework execute interface though
						execute_result_available => ???,
						execute_target	=> execute_target_int,
						memory_result => memory_result_int,
						memory_result_available	=> ???, --Same with this and above
						memory_target	=> memory_target_int,
						read_data_1	=> read_data_1_int,
						read_data_2	=> read_data_2_int,
						immediate => immediate_int,
						opcode => opcode_int,
						funct	=> funct_int,
						shamt	=> shamt_int,
						target => decode_target_int,
						read	=> memory_read_int1,
						write	=> memory_write_int1,
						use_execute_result => ???, --If we go with the above version, 
						use_memory_result	=> ???); --These two signals aren't necessary
						
						
	executeStage : execute PORT MAP ( 
						clock => clock, 
						opcode => opcode_int,
						shamt => shamt_int,
						funct => funct_int,
						read_data_1 => read_data_1_int,
						read_data_2 => read_data_2_int,
						immediate => immediate_int,
						execute_1_use_execute => ???,
						execute_2_use_execute => ???,
						execute_1_use_memory => ???,
						execute_2_use_memory => ???,
						memory_result => memory_result_int,
						next_target => decode_target_int,
						program_counter => ???,
						result => execute_result_int,
						branch_address => branch_address_int
						branch_taken => branch_taken_int
						target => execute_target_int);

						
	memoryStage : memory PORT MAP ( 
						clock => clock, 
						next_target => execute_target_int,
						memory_read => memory_read_int,
						memory_write => memory_write_int,
						address => execute_result_int,
						write_data => memory_write_data_int,
						result => memory_result_int,
						result_available => ???, --Is this to mean the result is MEANINGFUL? But no, 0 read/write is high
						target => memory_target_int,
						);
	
	------------------ Buffer Registers ------------------
	--Buffer intermediate registers (wait a clock cycle as execute runs)
	PROCESS(clock)
	BEGIN
      -- convention: rt is read_data_2 (operator2)
		IF rising_edge(clock) THEN
			memory_read_int2 <= memory_read_int1;
			memory_write_int2 <= memory_write_int1;
			memory_write_data_int <= read_data_2;
		END IF;
	END PROCESS;


END processor_arch;
