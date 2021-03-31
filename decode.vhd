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
			case I(31 downto 26) is
				--Register operation
				when "000000" =>
				
				
				--Jump
				when "000010" =>
				
				--Jump&Link
				when "000011" =>
				
				--BEQ
				when "000100" =>
					--Sign extend immediate (?)
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--BNE
				when "000101" =>
					--Sign extend immediate (?)
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--Add Imm
				when "001000" =>
					--Register Rs
					read_data_1 <= rFile(to_integer(unsigned(I(25 downto 21)));
					--Sign extended Imm val
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
					execOp <= ;
				
				--Set Less Than Imm
				when "001010" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--AND Imm
				when "001100" =>
					--Zero extend Imm
					immediate <= rFile(0)(31 downto 16) & I(15 downto 0);
					
				
				--OR Imm
				when "001101" =>
					--Zero extend Imm
					immediate <= rFile(0)(31 downto 16) & I(15 downto 0);
				
				--XOR Imm
				when "001110" =>
					--Zero extend Imm
					immediate <= rFile(0)(31 downto 16) & I(15 downto 0);
				
				--Load Upper Imm
				when "001111" =>
					immediate <=  I(15 downto 0) & rFile(0)(31 downto 16);
				
				--Load Word
				when "100011" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
				
				--Store Word
				when "101011" =>
					immediate <= std_logic_vector(resize(signed(I(15 downto 0)), 32));
					
				when others =>
				
			end case;
		
		end if;
	end process;

END decArch;

