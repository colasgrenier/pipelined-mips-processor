library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY execute IS
	PORT (
	   clock     			: in std_logic;
		opcode	   		: in std_logic_vector(7 downto 0);    -- opcode (given by the decode stage).
		shamt					: in std_logic_vector(4 downto 0);    -- shift amount (given by the decode stage)
		funct					: in std_logic_vector(7 downto 0);    -- function (given by the decode stage)
		read_data_1			: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_2			: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate			: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		next_target			: in std_logic_vector(4 downto 0);    -- the target register of the next phase.
		program_counter	: in std_logic_vector(31 downto 0);   -- next instruction address.
		result				: out std_logic_vector(31 downto 0);  -- result of the ALU operation.
		address				: out std_logic_vector(31 downto 0);  -- computed PC address.
		taken					: out std_logic;					  -- indicated whether the branch has been taken.
		target				: out std_logic_vector(4 downto 0)   -- the target register if there is a write to a register
    );
END ENTITY;

ARCHITECTURE alu_arch OF execute IS
    signal hi   : std_logic_vector(31 downto 0);
    signal lo   : std_logic_vector(31 downto 0);

BEGIN
	PROCESS(clock)
	BEGIN
        -- convention: rs is read_data_1; rt is read_data_2
		IF rising_edge(clock) THEN
			-- all signals are set to 0.
			result <= x"00000000";
			address <= x"00000000";
			taken <= '0';
			-- transfer the target register
			target <= next_target;
			
			
			-- operate depending on opcode.
			CASE opcode IS
				WHEN x"00" =>
					CASE funct IS
						WHEN x"00" =>
							-- sll rd = rt << shamt instruction.
							result <= std_logic_vector(shift_left(unsigned(read_data_2), to_integer(unsigned(shamt))));
						WHEN x"02" =>
							-- srl rd = rt >> shamt instruction.
							result <= std_logic_vector(shift_right(unsigned(read_data_2), to_integer(unsigned(shamt))));
						WHEN x"03" =>
							-- sra rd = rt >>> shamt instruction.
							result <= std_logic_vector(shift_right(signed(read_data_2), to_integer(unsigned(shamt))));
						WHEN x"08" =>
							-- jr pc=rs instruction.
							address <= read_data_1;
							taken <= '1';
						WHEN x"10" =>
							-- mfhi rd=hi instruction.
							result <= hi;
						WHEN x"12" =>
							-- mflo rd=lo instruction.
							result <= lo;
						WHEN x"18" =>
							-- mult hi,lo = rs*rt instruction.
							hi <= std_logic_vector("*"(signed(read_data_1),signed(read_data_2)) (63 downto 32));
							lo <= std_logic_vector("*"(signed(read_data_1),signed(read_data_2)) (31 downto 0));
						WHEN x"1a" =>
							-- div lo=rs/rt hi=rs%rt instruction.
							hi <= std_logic_vector(signed(read_data_1) mod signed(read_data_2));
							lo <= std_logic_vector(signed(read_data_1) / signed(read_data_2));
						WHEN x"20" =>
							-- add rd=rs+rtinstruction.
							result <= std_logic_vector(signed(read_data_1) + signed(read_data_2));
						WHEN x"22" =>
							-- sub rd=rs-rt  instruction.
							result <= std_logic_vector(signed(read_data_1) - signed(read_data_2));
						WHEN x"24" =>
							-- and rd=rs&rt instruction.
							result <= read_data_1 and read_data_2;
						WHEN x"25" =>
							-- or rd=rs|rt instruction.
							result <= read_data_1 or read_data_2;
						WHEN x"26" =>
							-- xor rd=rs^rd instruction.
							result <= read_data_1 xor read_data_2;
						WHEN x"27" =>
							-- nor rd=~(rs|rd) instruction.
							result <= read_data_1 nor read_data_2;
						WHEN x"2a" =>
							-- slt rd=(rs<rt)?1:0 instruction.
							IF signed(read_data_1) < signed(read_data_2) THEN
                            result <= x"00000001";
							ELSE
                            result <= x"00000000";
							END IF;
						WHEN OTHERS =>
							report "CASE ERRORS";
						END CASE;
				WHEN x"02" =>
					-- j instruction.
					address <= program_counter(31 downto 28) & immediate(25 downto 0) & "00";
					taken <= '1';
				WHEN x"03" =>
					-- jal instruction.
					address <= program_counter(31 downto 28) & immediate(25 downto 0) & "00";
					result <= program_counter;
					taken <= '1';
				WHEN x"04" =>
					-- beq if(rs==rt): pc=pc+4+branchaddr instruction.
					IF (read_data_1 = read_data_2) THEN
						address <= std_logic_vector(signed(program_counter) + signed(immediate) + "0100");
						taken <= '1';
					END IF;
				WHEN x"05" =>
					-- bne if(rs!=rt): pc=pc+4+branchaddr instruction.
					IF read_data_1 /= read_data_2 THEN
						address <= std_logic_vector(signed(program_counter) + signed(immediate) + "0100");
						taken <= '1';
					END IF;				
				WHEN x"08" =>
					-- addi rt=rs+immediate (sign-extended)
					result <= std_logic_vector(signed(read_data_1) + signed(immediate));
				WHEN x"0a" =>
					-- slti rt=rs<immediate (sign-extended) ? 1:0 
					IF signed(read_data_1) < signed(immediate) THEN
							 result <= x"00000001";
					ELSE
							 result <= x"00000000";
					END IF;
				WHEN x"0c" =>
					-- andi rt=rs&immediate (zero-extended)
					result <= read_data_1 and immediate;
				WHEN x"0d" =>
					-- ori rt=rs|immediate (zero-extended)
					result <= read_data_1 or immediate;
				WHEN x"0e" =>
					-- xori rt=rs^immediate (zero-extended)
					result <= read_data_1 xor immediate;
				WHEN x"0f" =>
					-- <lui> <rt> <immediate> instruction.
					--rt = {imm,x0000}
					result <= immediate(15 downto 0) & x"0000";
				WHEN x"23" =>
					-- lw instruction.
					-- rt=M[rs+signextendedimmediate]
					-- result is the computed address
					result <= std_logic_vector(signed(read_data_1) + signed(immediate));
				WHEN x"2b" =>
				   -- sw instruction.
				   -- M[rs+signextendedimmediate]=rt
				   -- result is the computed address
				   result <= std_logic_vector(signed(read_data_1) + signed(immediate));
				WHEN others =>
				  report "Case error";
				END CASE;
		END IF;
	END PROCESS;
END alu_arch;




