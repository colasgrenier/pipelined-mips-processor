ENTITY decode IS
	PORT (
		clock				: in std_logic; --Clock
		instruction			: in std_logic_vector(31 downto 0); --Instruction
		execute_result			: in std_logic_vector(31 downto 0);
		execute_result_available	: in std_logic;
		execute_target			: in std_logic_vector(4 downto 0);
		memory_result			: in std_logic_vector(31 downto 0);
		memory_result_available		: in std_logic;
		memory_target			: in std_logic_vector(4 downto 0);
		read_data_1			: out std_logic_vector(31 downto 0); -- data read from the 
		read_data_2			: out std_logic_vector(31 downto 0);
		immediate			: out std_logic_vector(31 downto 0);
		opcode				: out std_logic_vector(5 downto 0);
		funct				: out std_logic_vector();
		shamt				: out std_logic_vector();
		target 				: out std_logic_vector(4 downto 0);
		read				: out std_logic;
		write				: out std_logic;
	);
END decode;
	
ARCHITECTURE decode_arch of decode IS
	TYPE register_file_content_type IS ARRAY(31 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL register_file	: register_file_content_type;
	VARIABLE stall_count	: integer;
	SIGNAL read_address_1	: std_logic_vector(4 downto 0);
	SIGNAL read_address_2	: std_logic_vector(4 downto 0);
BEGIN
	PROCESS (clock) BEGIN
		-- Initialize the registers to 0.
		IF now < 1ps THEN
			FOR i IN 0 to 31 LOOP
				register_file_contents(i) <= x"00000000";
			END LOOP;
		END IF;
		-- We write to the register file on the rising edge.
		IF rising_edge(clock) THEN
			IF write_address /= "00000" THEN
				register_file_contents(to_integer(unsigned(write_address))) <= write_data;
			END IF;
		END IF;
		-- We read all registers & send the instruction details to execute on the falling edge.
		IF falling_edge(clock) THEN
			IF stall_count = 0 THEN
				-- No stalls are active.
				CASE instruction(31 downto 26) IS
					WHEN "0000" =>
						-- R type instruction.
						IF execute_target = instruction(25 downto 21) OR execute_target = instruction(20 downto 16) THEN
							-- If the execute stage is computing a result that will write to one of the read
							-- registers, stall for three cycles.
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSIF memory_target = instruction(25 downto 21) OR memory_target = instruction(20 downto 16) THEN
							-- If the memory stage will write to one of the read registers, stall for one cycle.
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSE
							-- Continue normally.
							read_data_1 <= register_file_contents(to_integer(unsigned(instruction(25 downto 21))));
							read_data_2 <= register_file_contents(to_integer(unsigned(instruction(20 downto 16))));
							target <= instruction(15 downto 11);
							opcode <= instruction(31 downto 26);
							shamt <= instruction(10 downto 6);
							funct <= instruction(5 downto 0);
							read <= '0';
							write <= '0';
						END IF;
					WHEN x"4" | x"5" | x"8" | "" =>
						-- I type instruction with sign-extension.
						IF execute_target = instrution(25 downto 21) THEN
							-- The execut
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSIF memory_target = instruction(25 downto 21) THEN
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSE
							opcode <= instruction(31 downto 26);
							read_data_1 <= register_file_contents(to_integer(unsigned(instruction(25 downto 21))));
							target <= instruction(20 downto 16);
							immediate <= std_logic_vector(resize(signed(instruction(15 downto 0)), 32));
							read <= '0';
							write <= '0';
						END IF;
					WHEN x"a" | x"c" | x"d" | "001110" | x"2b" | x"23" =>
						-- I type instruction with zero-extension.
						IF execute_target = instrution(25 downto 21) THEN
							-- The execut
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSIF memory_target = instruction(25 downto 21) THEN
							count := 2;
							opcode <= "000000";
							target <= "00000";
							read <= '0';
							write <= '0';
						ELSE
							opcode <= instruction(31 downto 26);
							read_data_1 <= register_file_contents(to_integer(unsigned(instruction(25 downto 21))));
							target <= instruction(20 downto 16);
							immediate <= x"0000" & instruction(15 downto 0);
							IF opcode = x"2b" =>
								read <= '1';
								write <= '0';
							ELSIF opcode = x"23" =>
								read <= '0';
								write <= '1';
							ELSE
								read <= '0';
								write <= '0';
							END IF;
								
						END IF;
					WHEN x"2" | x"3" =>
						-- J type instruction.
						opcode <= instruction(31 downto 6);
						immediate <= std_logic_vector(resize(unsigned(I(25 downto 0)), 32));
				END CASE;
			ELSE
				-- Reduce the stall count.
				count := count - 1;
			END IF;
		END IF;
	END PROCESS;
END decode_arch;

