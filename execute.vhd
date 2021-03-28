ENTITY execute IS
	PORT (
		opcode		: in std_logic_vector(4 downto 0);    -- instruction.
		read_data_1	: in std_logic_vector(31 downto 0);   -- data from register file.
		read_data_1	: in std_logic_vector(31 downto 0);   -- data from register file.
		immediate	: in std_logic_vector(31 downto 0);   -- immediate value from instruction.
		result		: out std_logic_vector(31 downto 0);  -- result of the ALU operation.
		address		: out std_logic_vector(31 downto 0);  -- computed address.
		target		: out std_logic_vector(4 downto 0);   -- target register for forwarding.
    );
END ENTITY;

ENTITY alu IS
	PORT (
		clock;
		instruction	: in std_logic_vector(31 downto 0);
		read_data_1	: in std_logic_vector(31 downto 0);
		read_data_1	: in std_logic_vector(31 downto 0);
		immediate	: in std_logic_vector(31 downto 0);
		result		: out std_logic_vector(31 downto 0);
	);
END ENTITY;

ARCHITECTURE alu_arch OF alu IS
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
		IF rising_edge(clock) THEN
			CASE opcode IS
				WHEN x"0" =>
					CASE function IS
						WHEN x"00" =>
							-- sll rd = rt << shamt instruction.
						WHEN x"02" =>
							-- srl rd = rt >> shamt instruction.
						WHEN x"03" =>
							-- sra rd = rt >>> shamt instruction.
						WHEN x"08" =>
							-- jr pc=rs instruction.
						WHEN x"10" =>
							-- <mfhi> <rd> instruction.
						WHEN x"12" =>
							-- <mflo> <rd> instruction.
						WHEN x"18" =>
							-- mult hi,lo = rs*rt instruction.
						WHEN x"1a" =>
							-- div lo=rs/rt hi=rs%rt instruction.
						WHEN x"20" =>
							-- add rd=rs+rtinstruction.
						WHEN x"22" =>
							-- sub rd=rs-rt  instruction.
						WHEN x"24" =>
							-- and rd=rs&rt instruction.
						when x"25" =>
							-- or rd=rs|rd instruction.
						WHEN x"27" =>
							-- <nor> <rd> <rs> <rt> instruction.
						WHEN x"2a" =>
							-- <slt> <rd> <rs> <rt> instruction.

					END CASE;
				WHEN x"3" =>
					-- j instruction.
				WHEN x"3" =>
					-- jal instruction.
				WHEN x"4" =>
					-- beq if(rs==rt): pc=pc+4+branchaddr instruction.
				WHEN x"5" =>
					-- nbe if(rs!=rt): pc=pc+4+branchaddr instruction.
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


