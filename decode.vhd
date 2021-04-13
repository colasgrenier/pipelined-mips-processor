ENTITY decode IS
	PORT (
		clock				: in std_logic; --Clock
		instruction			: in std_logic_vector(31 downto 0); --Instruction
		read_data_1			: out std_logic_vector(31 downto 0); -- data read from the 
		read_data_2			: out std_logic_vector(31 downto 0);
		immediate			: out std_logic_vector(31 downto 0);
		execute_result			: in std_logic_vector(31 downto 0);
		execute_result_available	: in std_logic;
		execute_target			: in std_logic_vector(4 downto 0);
		memory_result			: in std_logic_vector(31 downto 0);
		memory_result_available		: in std_logic;
		memory_target			: in std_logic_vector(4 downto 0);
	);
END decode;

ENTITY register_file IS
	PORT (
		clock		: in std_logic;
		read_address_1	: in std_logic_vector(4 downto 0);
		read_address_2	: in std_logic_vector(4 downto 0);
		write_address	: in std_logic_Vector(4 downto 0);
		write_data	: in std_logic_vector(31 downto 0);
		read_data_1	: out std_logic_vector(31 downto 0);
		read_data_2	: out std_logic_vector(31 downto 0);
	);
END register_file;
	
ARCHITECTURE register_file_arch of register_file IS
	TYPE register_file_content_type IS ARRAY(31 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL register_file_contents	: register_file_content_type;
BEGIN
	PROCESS (clock) BEGIN
		-- Initialize the registers to 0.
		IF now < 1ps THEN
			FOR i IN 0 to 31 LOOP
				register_file_contents(i) <= x"00000000";
			END LOOP;
		END IF;
		-- We write all data on the rising edge.
		IF rising_edge(clock) THEN
			IF write_address /= "00000" THEN
				register_file_contents(to_integer(unsigned(write_address))) <= write_data;
			END IF;
		END IF;
		-- We read all data on the falling edge.
		IF falling_edge(clock) THEN
			read_data_1 <= register_file_contents(to_integer(unsigned(read_address_1)));
			read_data_2 <= register_file_contents(to_integer(unsigned(read_address_2)));
		END IF;
	END PROCESS;
	PROCESS (read_address_1, read_address_2) BEGIN
		
	END PROCESS;
END register_file_arch;
	
	
ARCHITECTURE decArch OF decode IS 
--31 Registers of 32 bits each
TYPE REGISTER_MEM IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL rFile : REGISTER_MEM;

BEGIN
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
					

