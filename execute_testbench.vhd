library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY execute_testbench IS
END ENTITY;

ARCHITECTURE behavioural OF execute_testbench IS
  
  COMPONENT execute IS
	   PORT (
	    clock     			: in std_logic;
		  opcode	   		: in std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
		  shamt					: in std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
		  funct					: in std_logic_vector(7 downto 0);    -- function (given by the decode stage)
		  read_data_1			: in std_logic_vector(31 downto 0);   -- data from register file.
		  read_data_2			: in std_logic_vector(31 downto 0);   -- data from register file.
		  immediate			: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		  target				: in std_logic_vector(4 downto 0);    -- the target register of the current phase.
		  program_counter	: in std_logic_vector(31 downto 0);   -- next instruction address.
		  result				: out std_logic_vector(31 downto 0);  -- result of the ALU operation.
		  PC_out				: out std_logic_vector(31 downto 0);  -- computed PC address.
		  branch_taken		: out std_logic;					  		  -- indicated whether the branch has been taken.
		  next_target			: out std_logic_vector(4 downto 0)    -- the target register of the next phase (if there is a write to a register)
    );
  END COMPONENT;

  	-- Test signals.
	SIGNAL reset		: std_logic := '0';
	SIGNAL clock		: std_logic := '0';
	CONSTANT clock_period	: time := 1 ns;
	
	-- Interconnects
	SIGNAL etb_opcode : std_logic_vector(5 downto 0) := "000000"; 
	SIGNAL etb_shamt : std_logic_vector(4 downto 0) := "00000";
	SIGNAL etb_funct : std_logic_vector(7 downto 0) := "00000000"; 
	SIGNAL etb_rd_1 : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_rd_2 : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_immediate : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_target : std_logic_vector(4 downto 0)  := "00000";
	SIGNAL etb_pc : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_result : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_pc_out : std_logic_vector(31 downto 0) := x"00000000";
	SIGNAL etb_branch_taken : std_logic := '0';
	SIGNAL etb_next_target : std_logic_vector(4 downto 0) := "00000";
	
  BEGIN
    EX: execute
    port map(
      clock => clock,
      opcode => etb_opcode,
      shamt => etb_shamt,
      funct => etb_funct,
      read_data_1 =>etb_rd_1,
      read_data_2 => etb_rd_2,
      immediate => etb_immediate,
      target => etb_target,
      program_counter => etb_pc,
      result => etb_result,
      PC_out => etb_pc_out,
      branch_taken => etb_branch_taken,
      next_target => etb_next_target
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
		
		-- Tests
		-- Sll
	  etb_opcode <= "000000";
		etb_funct <= x"00"; 
		etb_rd_2 <= x"00000010";
		etb_shamt <= "00001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = "00000000000000000000000000100000" REPORT "SLL Error" SEVERITY FAILURE;
		
		-- SRL
	  etb_opcode <= "000000";
		etb_funct <= x"02"; 
		etb_rd_2 <= x"00000010";
		etb_shamt <= "00001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = "00000000000000000000000000001000" REPORT "SRL Error" SEVERITY FAILURE;
		
		-- SRA 
		etb_opcode <= "000000";
		etb_funct <= x"03"; 
		etb_rd_2 <= x"00000010";
		etb_shamt <= "00001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = "00000000000000000000000000001000" REPORT "SRA Error" SEVERITY FAILURE;
		
		-- BRANCH
		etb_opcode <= "000000";
		etb_funct <= x"08"; 
		etb_rd_1 <= x"00000011";
		WAIT FOR 1*clock_period;
		ASSERT etb_pc_out = x"00000011" REPORT "BRANCH Error" SEVERITY FAILURE;
		ASSERT etb_branch_taken = '1' REPORT "BRANCH Error" SEVERITY FAILURE;
		
		-- Hi
		-- Lo
		-- Mult
		-- Div
		
		-- AND
		etb_opcode <= "000000";
		etb_funct <= x"24";
		etb_rd_1 <= x"00000011";
		etb_rd_2 <= x"00000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = x"00000001" REPORT "AND Error" SEVERITY FAILURE;
		
		-- OR
	  etb_opcode <= "000000";
		etb_funct <= x"25";
		etb_rd_1 <= x"00000011";
		etb_rd_2 <= x"00000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = x"00000011" REPORT "OR Error" SEVERITY FAILURE;
		
		-- XOR
	  etb_opcode <= "000000";
		etb_funct <= x"26";
		etb_rd_1 <= x"00000011";
		etb_rd_2 <= x"00000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = x"00000010" REPORT "XOR Error" SEVERITY FAILURE;
				
		-- NOR
		etb_opcode <= "000000";
		etb_funct <= x"27";
		etb_rd_1 <= x"01111111";
		etb_rd_2 <= x"00000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = "11111110111011101110111011101110" REPORT "NOR Error" SEVERITY FAILURE;
		
		-- LT / GT
		etb_opcode <= "000000";
		etb_funct <= x"2a";
		etb_rd_1 <= x"01111111";
		etb_rd_2 <= x"00000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = x"00000000" REPORT "LT Error" SEVERITY FAILURE;
		etb_rd_1 <= x"01111111";
		etb_rd_2 <= x"10000001";
		WAIT FOR 1*clock_period;
		ASSERT etb_result = x"00000001" REPORT "GT Error" SEVERITY FAILURE;
		
    
		
		
	END PROCESS;
END;
  

