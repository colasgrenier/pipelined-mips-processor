library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY execute IS
	PORT (
	   clock     			: in std_logic;
		opcode	   		: in std_logic_vector(5 downto 0);    -- opcode (given by the decode stage).
		shamt					: in std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
		funct					: in std_logic_vector(7 downto 0);    -- function (given by the decode stage)
		read_data_1			: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_2			: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate			: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		
		
		execute_use_1_execute 		: in std_logic; --control use execute result in port 1
		execute_use_2_execute		: in std_logic; --control use execute result in port 2
		execute_use_1_memory			: in std_logic; --control use mem result in port 1
		execute_use_2_memory			: in std_logic; --control use mem result in port 2
		memory_use_memory_in			: in std_logic; --buffer if mem should use mem result
		memory_result					: in std_logic_vector(31 downto 0); --result of mem stage (for forwarding)
		
		next_target			: in std_logic_vector(4 downto 0);    -- the target register of the next instruction.
		program_counter	: in std_logic_vector(31 downto 0);   -- next instruction address.
		
		memory_use_memory_out		: out std_logic;
		
		result				: out std_logic_vector(31 downto 0);  -- result of the ALU operation. (Inout for forwarding)
		PC_out				: out std_logic_vector(31 downto 0);  -- computed PC address.
		branch_taken		: out std_logic;					  		  -- indicated whether the branch has been taken.
		target				: out std_logic_vector(4 downto 0)    -- the target register of the current phase
    );
END ENTITY;

ARCHITECTURE alu_arch OF execute IS
    signal hi   : std_logic_vector(31 downto 0);
    signal lo   : std_logic_vector(31 downto 0);
	 
	 --replaces opcode, Helpful in the switch-case for 8 bits
	 signal op 	 : std_logic_vector(7 downto 0);
	 
	 --Used to ignore last 2 (?) I if a branch was taken
	 --todo later (flushing on branch)
	 --signal lastIBranched : std_logic(1 downto 0);
	 
	 --Operator 1/2, hold ALU inputs (may be forwarded)
	 signal operator1: std_logic_vector(31 downto 0);
	 signal operator2: std_logic_vector(31 downto 0);
	 
	 
	 --Can't read from output port, so we'll assign result here
	 signal inner_result : std_logic_vector(31 downto 0);

BEGIN
	--permanent connection from inner_result to ouput result
	result <= inner_result;
	
	op <= "00" & opcode;
	
	--Implement forwarding
	operator1 <= inner_result when execute_use_1_execute = '1' else
				memory_result when execute_use_1_memory = '1' else
				read_data_1;
	operator2 <= inner_result when execute_use_2_execute = '1' else
				memory_result when execute_use_2_memory	 = '1' else
				read_data_2;
	
	PROCESS(clock)
	BEGIN
      -- convention: rs is read_data_1 (operator1); rt is read_data_2 (operator2)
		IF rising_edge(clock) THEN
			-- all signals are set to 0.
			inner_result <= x"00000000";
			PC_out <= x"00000000";
			branch_taken <= '0';
			-- transfer the target register
			target <= next_target;
			memory_use_memory_out	 <= memory_use_memory_in;
			
			
			-- operate depending on opcode.
			CASE op IS
				WHEN x"00" =>
					CASE funct IS
						WHEN x"00" =>
							-- sll rd = rt << shamt instruction.
							inner_result <= std_logic_vector(shift_left(unsigned(operator2), to_integer(unsigned(shamt))));
						WHEN x"02" =>
							-- srl rd = rt >> shamt instruction.
							inner_result <= std_logic_vector(shift_right(unsigned(operator2), to_integer(unsigned(shamt))));
						WHEN x"03" =>
							-- sra rd = rt >>> shamt instruction.
							inner_result <= std_logic_vector(shift_right(signed(operator2), to_integer(unsigned(shamt))));
						WHEN x"08" =>
							-- jr pc=rs instruction.
							PC_out <= operator1;
							branch_taken <= '1';
						WHEN x"10" =>
							-- mfhi rd=hi instruction.
							inner_result <= hi;
						WHEN x"12" =>
							-- mflo rd=lo instruction.
							inner_result <= lo;
						WHEN x"18" =>
							-- mult hi,lo = rs*rt instruction.
							hi <= std_logic_vector("*"(signed(operator1),signed(operator2)) (63 downto 32));
							lo <= std_logic_vector("*"(signed(operator1),signed(operator2)) (31 downto 0));
						WHEN x"1a" =>
							-- div lo=rs/rt hi=rs%rt instruction.
							hi <= std_logic_vector(signed(operator1) mod signed(operator2));
							lo <= std_logic_vector(signed(operator1) / signed(operator2));
						WHEN x"20" =>
							-- add rd=rs+rtinstruction.
							inner_result <= std_logic_vector(signed(operator1) + signed(operator2));
						WHEN x"22" =>
							-- sub rd=rs-rt  instruction.
							inner_result <= std_logic_vector(signed(operator1) - signed(operator2));
						WHEN x"24" =>
							-- and rd=rs&rt instruction.
							inner_result <= operator1 and operator2;
						WHEN x"25" =>
							-- or rd=rs|rt instruction.
							inner_result <= operator1 or operator2;
						WHEN x"26" =>
							-- xor rd=rs^rd instruction.
							inner_result <= operator1 xor operator2;
						WHEN x"27" =>
							-- nor rd=~(rs|rd) instruction.
							inner_result <= operator1 nor operator2;
						WHEN x"2a" =>
							-- slt rd=(rs<rt)?1:0 instruction.
							IF signed(operator1) < signed(operator2) THEN
                            inner_result <= x"00000001";
							ELSE
                            inner_result <= x"00000000";
							END IF;
						WHEN OTHERS =>
							REPORT "EXECUTE CASE ERRORS (R Instruction)" severity failure;
						END CASE;
				WHEN x"02" =>
					-- j instruction.
					--PC = JumpAddress = { PC+4[31:28], address, 2’b0 }
					PC_out <= std_logic_vector(
									 "+"(unsigned(program_counter), "0100")(31 downto 28))
								  & immediate(25 downto 0) 
								  & "00";
					branch_taken <= '1';
				WHEN x"03" =>
					-- jal instruction.
					--PC = JumpAddress = { PC+4[31:28], address, 2’b0 }
					--R[31] = PC+8
					PC_out <= std_logic_vector(
									 "+"(unsigned(program_counter), "0100")(31 downto 28))
								  & immediate(25 downto 0) 
								  & "00";
					inner_result <= std_logic_vector(unsigned(program_counter) + "1000");
					branch_taken <= '1';
				WHEN x"04" =>
					-- beq if(rs==rt): pc=pc+4+branchaddr instruction.
					-- BranchAddr = { 14{immediate[15]}, immediate, 2’b0 }
					IF operator1 = operator2 THEN
						PC_out <= std_logic_vector( unsigned(program_counter) + "0100" + 
															  unsigned((immediate(29 downto 0)&"00")));
						branch_taken <= '1';
					END IF;
				WHEN x"05" =>
					-- bne if(rs!=rt): pc=pc+4+branchaddr instruction.
					-- BranchAddr = { 14{immediate[15]}, immediate, 2’b0 }
					IF operator1 /= operator2 THEN
						PC_out <= std_logic_vector( unsigned(program_counter) + "0100" + 
															  unsigned((immediate(29 downto 0)&"00")));
						branch_taken <= '1';
					END IF;				
				WHEN x"08" =>
					-- addi rt=rs+immediate (sign-extended)
					inner_result <= std_logic_vector(signed(operator1) + signed(immediate));
				WHEN x"0a" =>
					-- slti rt=rs<immediate (sign-extended) ? 1:0 
					IF signed(operator1) < signed(immediate) THEN
							 inner_result <= x"00000001";
					ELSE
							 inner_result <= x"00000000";
					END IF;
				WHEN x"0c" =>
					-- andi rt=rs&immediate (zero-extended)
					inner_result <= operator1 and immediate;
				WHEN x"0d" =>
					-- ori rt=rs|immediate (zero-extended)
					inner_result <= operator1 or immediate;
				WHEN x"0e" =>
					-- xori rt=rs^immediate (zero-extended)
					inner_result <= operator1 xor immediate;
				WHEN x"0f" =>
					-- <lui> <rt> <immediate> instruction.
					--lui rt = {imm,x0000}
					inner_result <= immediate(15 downto 0) & x"0000";
				WHEN x"23" =>
					-- lw instruction.
					-- rt=M[rs+signextendedimmediate]
					-- result is the computed address
					inner_result <= std_logic_vector(signed(operator1) + signed(immediate));
				WHEN x"2b" =>
				   -- sw instruction.
				   -- M[rs+signextendedimmediate]=rt
				   -- result is the computed address
				   inner_result <= std_logic_vector(signed(operator1) + signed(immediate));
				WHEN others =>
				  REPORT "EXECUTE CASE ERRORS (J/I Instruction)" severity failure;
				END CASE;
		END IF;
	END PROCESS;
END alu_arch;




