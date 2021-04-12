ENTITY decode IS
	PORT (
		clk			: in std_logic; --Clock
		I				: in std_logic_vector(31 downto 0); --Instruction
		writeAddr	: in std_logic_vector(4 downto 0); --Probably -> writeback when registers separated
		writeData	: in std_logic_vector(31 downto 0); --^ ditto
		read_data_1	: out std_logic_vector(31 downto 0); -- data read from the 
		read_data_2	: out std_logic_vector(31 downto 0);
		immediate	: out std_logic_vector(31 downto 0);
		
		execOp		: out std_logic_vector(2 downto 0);
		--To add: rest of the control sigs
	);
END decode;


ARCHITECTURE decArch OF decode IS 
--31 Registers of 32 bits each
TYPE REGISTER_MEM IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL rFile : REGISTER_MEM;

BEGIN
	--Idea: to write in first half read in second, 
	--we read on falling edge of clock
	--Though this is kind of stealing write_back's work
	--Idk, we'll have to decide
	--I'm guessing we'll separate the register files out so ig this won't be as easy
	process (clk)
	begin
		if rising_edge(clk) then
			if writeAddr /= "0000" then
				rFile(to_integer(unsigned(writeAddr))) <= writeData;
			end if;
		else if falling_edge(clk) then
			case unsigned(I(31 downto 26)) is
				--Register operation
				when x"00" =>
				
				
				--Jump
				when x"02" =>
				
				--Jump&Link
				when x"03" =>
				
				--BEQ
				when x"04" =>
					--Sign extend immediate (?)
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--BNE
				when x"05" =>
					--Sign extend immediate (?)
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--Add Imm
				when x"08" =>
					--Register Rs
					read_data_1 <= rFile(to_integer(unsigned(I(25 downto 21)));
					--Sign extended Imm val
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
					execOp <= ;
				
				--Set Less Than Imm
				when x"0A" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--AND Imm
				when x"0C" =>
					--Zero extend Imm
					immediate <= std_logic_vector(x"00") & I(15 downto 0);
					
				
				--OR Imm
				when x"0D" =>
					--Zero extend Imm
					immediate <= std_logic_vector(x"00") & I(15 downto 0);
				
				--XOR Imm
				when x"0E" =>
					--Zero extend Imm
					immediate <= std_logic_vector(x"00") & I(15 downto 0);
				
				--Load Upper Imm
				when x"0F" =>
					immediate <=  I(15 downto 0) & std_logic_vector(x"00");
				
				--Load Word
				when x"23" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--Store Word
				when x"2B" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
					
				when others =>
				
			end case;
		
		end if;
	end process;

END decArch;

