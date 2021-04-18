library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY processor IS
    PORT (
        clock       : in std_logic;
        reset       : in std_logic
    );
END ENTITY;

ARCHITECTURE processor_arch OF processor IS
	------------------ Component declarations ------------------
	
	COMPONENT fetch PORT (
		clock		: in std_logic;
		stall		: in std_logic;				-- whether to continue to the next address or not.
		branch_taken	: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0);	-- instruction that was read.
		program_counter : out std_logic_vector(31 downto 0) --current program counter
	);
	END COMPONENT;
	
	COMPONENT decode PORT (
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
	
	
	COMPONENT execute PORT (
	   clock     			: in std_logic;
		opcode	   		: in std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
		shamt					: in std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
		funct					: in std_logic_vector(5 downto 0);    -- function (given by the decode stage)
		read_data_1			: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_2			: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate			: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		
		
		execute_1_use_execute 		: in std_logic; --control use execute result in port 1
		execute_2_use_execute		: in std_logic; --control use execute result in port 2
		execute_1_use_memory			: in std_logic; --control use mem result in port 1
		execute_2_use_memory			: in std_logic; --control use mem result in port 2
		memory_result					: in std_logic_vector(31 downto 0); --result of mem stage (for forwarding)
		program_counter	: in std_logic_vector(31 downto 0);   -- next instruction address.
		
		result				: out std_logic_vector(31 downto 0);  -- result of the ALU operation. (Inout for forwarding)
		memory_write_data : out std_logic_vector(31 downto 0);  --data to write to memory (just a buffer stage)
		branch_address		: out std_logic_vector(31 downto 0);  -- computed PC address.
		branch_taken		: out std_logic					  		  -- indicated whether the branch has been taken.
    );
	END COMPONENT;
	
	COMPONENT memory PORT (
		clock				: in std_logic;
		memory_read			: in std_logic;				-- must read from data memory.
		memory_write		: in std_logic;				-- must write to data memory.
		memory_use_memory : in std_logic; --Forwarding control
		memory_use_writeback : in std_logic; --Forwarding control
		writeback_data    : in std_logic_vector(31 downto 0);
		address				: in std_logic_vector(31 downto 0);
		write_data			: in std_logic_vector(31 downto 0);
		result				: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	COMPONENT writeback PORT (
		clock		: in std_logic;
		input		: in std_logic_vector(31 downto 0);
		result		: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	------------------Interconnection Signals------------------
	
	
	--int appended to internal signals
	SIGNAL branch_taken : std_logic;
	SIGNAL stall: std_logic;
	SIGNAL branch_address	: std_logic_vector(31 downto 0);	-- computed address for branch.
	SIGNAL instruction	: std_logic_vector(31 downto 0);	-- instruction
	
	SIGNAL opcode	: std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
	SIGNAL shamt	: std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
	SIGNAL funct	: std_logic_vector(5 downto 0);    -- function (given by the decode stage)
	SIGNAL read_data_1	: std_logic_vector(31 downto 0);   -- data from register file.
	SIGNAL read_data_2	: std_logic_vector(31 downto 0);   -- data from register file.
	SIGNAL immediate 	: std_logic_vector(31 downto 0);   -- immediate value from instruction.
	
	
	SIGNAL execute_1_use_execute, execute_2_use_execute,
			 execute_1_use_memory, execute_2_use_memory,
			 memory_use_memory, memory_use_writeback : std_logic; --forwarding control
	
	SIGNAL program_counter	: std_logic_vector(31 downto 0);   -- next instruction address.
	
	SIGNAL memory_result		: std_logic_vector(31 downto 0); --result of mem stage (for forwarding)
	SIGNAL execute_result	   : std_logic_vector(31 downto 0); -- result of the ALU operation.
	SIGNAL writeback_result   : std_logic_vector(31 downto 0); -- result of the writeback stage.
	

	SIGNAL memory_read, memory_write : std_logic;
	SIGNAL memory_write_data : std_logic_vector(31 downto 0);
	
	
BEGIN

	------------------ Instantiations ------------------
	
	fetchStage : fetch PORT MAP ( 
						clock => clock, 
						stall => stall,
						branch_taken => branch_taken,
						branch_address => branch_address,
						instruction => instruction,
						program_counter => program_counter);
						
	decodeStage : decode PORT MAP ( 
						clock => clock, 
						instruction => instruction,
						write_data => writeback_result,
						stall_fetch => stall,
						read_data_1 => read_data_1,
						read_data_2 => read_data_2,
						immediate => immediate,
						opcode => opcode,
						funct => funct,
						shamt => shamt,
						memory_read => memory_read,
						memory_write => memory_write,
						execute_1_use_execute => execute_1_use_execute,
						execute_2_use_execute => execute_2_use_execute,
						execute_1_use_memory => execute_1_use_memory,
						execute_2_use_memory => execute_2_use_memory,
						memory_use_memory => memory_use_memory,
						memory_use_writeback => memory_use_writeback); --These two signals aren't necessary
						
						
	executeStage : execute PORT MAP ( 
						clock => clock, 
						opcode => opcode,
						shamt => shamt,
						funct => funct,
						read_data_1 => read_data_1,
						read_data_2 => read_data_2,
						immediate => immediate,
						execute_1_use_execute => execute_1_use_execute,
						execute_2_use_execute => execute_2_use_execute,
						execute_1_use_memory => execute_1_use_memory,
						execute_2_use_memory => execute_2_use_memory,
						memory_result => memory_result,
						program_counter => program_counter,
						result => execute_result,
						memory_write_data => memory_write_data,
						branch_address => branch_address,
						branch_taken => branch_taken);

						
	memoryStage : memory PORT MAP ( 
						clock => clock, 
						memory_read => memory_read,
						memory_write => memory_write,
						
						memory_use_memory => memory_use_memory,
						memory_use_writeback => memory_use_writeback,
						writeback_data => writeback_result,
						
						address => execute_result,
						write_data => memory_write_data,
						result => memory_result);
						
	writebackStage : writeback PORT MAP (
						clock => clock, 
						input => memory_result,
						result => writeback_result);


END processor_arch;
