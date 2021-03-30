ENTITY execute IS
	PORT (
		opcode	   		: in std_logic_vector(4 downto 0);    -- instruction.
		read_data_1		: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_1		: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate		: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		program_counter		: in std_logic_vector(31 downto 0);   -- next instruction address.
		result			: out std_logic_vector(31 downto 0);  -- result of the ALU operation.
		address			: out std_logic_vector(31 downto 0);  -- computed address.
		taken			: out std_logic;					  -- indicated whether the branch has been taken.
		target			: out std_logic_vector(4 downto 0);   -- the target register if there is a write to a register
    );
END ENTITY;

ARCHITECTURE alu_arch OF execute IS
    signal hi   : std_logic_vector(31 downto 0);
    signal lo   : std_logic_vector(31 downto 0);
BEGIN
	PROCESS(clock)
	opcode <= instruction(31 downto 26);
	rs <=;
	rt <=;
	rd <=;
	shamt <= ;
	funct <=;
	address <= ;
	BEGIN
        -- convention: rs is read_data_1; rt is read_data_2
		IF rising_edge(clock) THEN
			-- all signals are set to 0.
			result <= x"00000000";
			address <= x"00000000";
			taken <= '1';
			-- operate depending on opcode.
			CASE opcode IS
				WHEN x"0" =>
					CASE function IS
						WHEN x"00" =>
							-- sll rd = rt << shamt instruction.
							result <= read_data_1 sll to_integer(unsigned(shamt));
						WHEN x"02" =>
							-- srl rd = rt >> shamt instruction.
							result <= read_data_1 srl to_integer(unsigned(shamt));
						WHEN x"03" =>
							-- sra rd = rt >>> shamt instruction.
							result <= read_data_1 sra to_integer(unsigned(shamt));
						WHEN x"08" =>
							-- jr pc=rs instruction.
							target <= read_data_1;
						WHEN x"10" =>
							-- mfhi rd=hi instruction.
							result <= hi;
						WHEN x"12" =>
							-- mflo rd=lo instruction.
							result <= lo;
						WHEN x"18" =>
							-- mult hi,lo = rs*rt instruction.
							hi <= std_logic_vector(to_unsigned(to_integer(unsigned(read_data_1))*to_integer(unsigned(read_data_2))))(63 downto 32);
							lo <= std_logic_vector(to_unsigned(to_integer(unsigned(read_data_1))*to_integer(unsigned(read_data_2))))(31 downto 0);
						WHEN x"1a" =>
							-- div lo=rs/rt hi=rs%rt instruction.
							hi <= std_logic_vector(signed(read_data_1) mod signed(read_data_2));
							lo <= std_logic_vector(signed(read_data_1) / signed(read_data_2));
						WHEN x"20" =>
							-- add rd=rs+rtinstruction.
							result <= std_logic_vector(signed(read_data_1) + signed(read_data_2));
						WHEN x"22" =>
							-- sub rd=rs-rt  instruction.
							result <= std_logic_vector(to_unsigned(to_integer(unsigned(read_data_1)) - to_integer(unsigned(read_data_2))));
						WHEN x"24" =>
							-- and rd=rs&rt instruction.
							result <= read_data_1 and read_data_2;
						when x"25" =>
							-- or rd=rs|rd instruction.
							result <= read_data_1 or read_data_2;
						WHEN x"27" =>
							-- nor rd=~(rs|rd) instruction.
							result <= read_data_1 nor read_data_2;
						WHEN x"2a" =>
							-- slt rd=(rs<rt)?1:0 instruction.
							IF (to_integer(signed(read_data_1)) < to_integer(signed(read_data_2))) THEN
                                result <= x"00000001";
							ELSE
                                result <= x"00000000";
							END IF;

					END CASE;
				WHEN x"3" =>
					-- j instruction.
					address <= program_counter(31 downto 28) & immediate & "00";
					taken <= '1';
				WHEN x"3" =>
					-- jal instruction.
					address <= program_counter(31 downto 28) & immediate & "00";
					result <= program_counter;
					taken <= '1';
				WHEN x"4" =>
					-- beq if(rs==rt): pc=pc+4+branchaddr instruction.
					IF (read_data_1 = read_data_2) THEN
						address <= program_counter + immediate;
						taken <= '1';
					END IF;
				WHEN x"5" =>
					-- bne if(rs!=rt): pc=pc+4+branchaddr instruction.
					IF (read_data_1 /= read_data_2) THEN
						address <= program_counter + immediate;
						taken <= '1';
					END IF;				
				WHEN x"8" =>
					-- <addi> <rt> <rs> <sign-extended immediate> instruction.
				WHEN x"c" =>
					-- <andi> <rt> <rs> <zero-extended immediate> instruction.
				WHEN x"f" =>
					-- <lui> <rt> <immediate> instruction.
				WHEN x"23" =>
					-- lw instruction.
				WHEN x"2b" =>
					-- sw instruction.
					
			END CASE;
		END IF;
	END PROCESS;
END alu_arch;


