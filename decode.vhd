library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY decode IS
	PORT (
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
		target 				: out std_logic_vector(4 downto 0);
		memory_read			: out std_logic;
		memory_write			: out std_logic;
		execute_1_use_execute		: out std_logic;
		execute_2_use_execute		: out std_logic;
		execute_1_use_memory		: out std_logic;
		execute_2_use_memory		: out std_logic;
		memory_use_execute		: out std_logic;
		memory_use_memory		: out std_logic
	);
END decode;
	
ARCHITECTURE decode_arch of decode IS
	TYPE register_file_content_type IS ARRAY(31 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL register_file			: register_file_content_type;		-- The 32 registers.			-- Counter for stalling.
	SIGNAL read_address_1			: std_logic_vector(4 downto 0);		-- 
	SIGNAL read_address_2			: std_logic_vector(4 downto 0);		--
	SIGNAL execute_target			: std_logic_vector(4 downto 0);		-- The target of the execute stage.
	SIGNAL execute_result_available_execute	: std_logic;				-- Whether the instruction presently in the execute stage will have its result available in the execute stage.
	SIGNAL execute_result_available_memory	: std_logic;				-- Whether the instruction presently in the execute stage will completehave its result available in the memory stage (pretty sure this is always the case).
	SIGNAL memory_target			: std_logic_vector(4 downto 0);		-- The target of the instruction presently in the memory stage
	SIGNAL memory_use_memory_buffer		: std_logic;				-- Buffer to hold the signal indicating to the memory stage to use the previous result of the memory stage (fowarding).
	SIGNAL writeback_target			: std_logic_vector(4 downto 0);
	SIGNAL memory_read_buffer		: std_logic;
	SIGNAL memory_write_buffer		: std_logic;
BEGIN
	PROCESS (clock)
		FILE register_file_file			: TEXT;
		VARIABLE register_file_line		: LINE;
		VARIABLE stall_counter			: integer;	
		VARIABLE opcode_v			: std_logic_vector(7 downto 0);
	BEGIN
		-- Initialize the registers to 0.
		IF now < 1 ps THEN
			FOR i IN 0 to 31 LOOP
				register_file(i) <= x"00000000";
			END LOOP;
		END IF;
		-- We write to the register file on the rising edge.
		IF rising_edge(clock) THEN
			IF writeback_target /= "00000" THEN
				register_file(to_integer(unsigned(writeback_target))) <= write_data;
			END IF;
		END IF;
		-- We write the register file to file every falling edge.
		IF falling_edge(clock) THEN
			file_open(register_file_file, "register_file.txt", WRITE_MODE);
			FOR line IN 0 TO 31 LOOP
				write(register_file_line, register_file(line));
				writeline(register_file_file, register_file_line);
			END LOOP;
			file_close(register_file_file);
		END IF;
		-- We read all registers & send the instruction details to execute on the falling edge.
		IF falling_edge(clock) THEN
			-- Set variables for the case.
			opcode_v := "00" & instruction(31 downto 26);
			-- Update the targets.
			writeback_target <= memory_target;
			memory_target <= execute_target;
			-- Shift the buffers.
			memory_use_memory <= memory_use_memory_buffer;
			IF stall_counter = 0 THEN
				-- No stalls are active.
				CASE opcode_v IS
					WHEN x"00" =>
						-- R type instruction.
						IF execute_target = instruction(25 downto 21) OR execute_target = instruction(20 downto 16) THEN
							-- The execute stage is computing a result that will be written to one of the read register.
							IF execute_result_available_execute = '1' THEN
								-- The result will be immediately available as the result of the execute stage.
								-- Stalling is not necessary.
								IF execute_target = instruction(25 downto 21) THEN
									-- The execute stages computes a value that will be written to RS.
									execute_1_use_execute <= '1';
									execute_2_use_execute <= '0';
								ELSE
									-- The execute stages computes a value that will be written to RT.
									execute_1_use_execute <= '1';
									execute_2_use_execute <= '0';
								END IF;
								execute_1_use_memory <= '0';
								execute_2_use_memory <= '0';
							ELSE
								-- The result will only be available as the result of the memory stage.
								-- We need to stall for one cycle.
								stall_counter := 1;
								IF execute_target = instruction(25 downto 21) THEN
									execute_1_use_memory <= '1';
								ELSE
									execute_2_use_memory <= '1';
								END IF;
								execute_1_use_execute <= '0';
								execute_2_use_execute <= '0';
							END IF;
							opcode <= "000000";
							target <= "00000";
							memory_read_buffer <= '0';
							memory_write_buffer <= '0';
						ELSIF memory_target = instruction(25 downto 21) OR memory_target = instruction(20 downto 16) THEN
							-- If the memory stage will write to one of the read registers, stall for one cycle.
							IF memory_target = instruction(25 downto 21) THEN
								execute_1_use_memory <= '1';
								execute_2_use_memory <= '0';
							ELSE
								execute_1_use_memory <= '0';
								execute_2_use_memory <= '1';
							END IF;
							stall_counter := 1;
							opcode <= "000000";
							target <= "00000";
							memory_read_buffer <= '0';
							memory_write_buffer <= '0';
							stall_fetch <= '1';
						ELSE
							-- Continue normally.
							read_data_1 <= register_file(to_integer(unsigned(instruction(25 downto 21))));
							read_data_2 <= register_file(to_integer(unsigned(instruction(20 downto 16))));
							target <= instruction(15 downto 11);
							opcode <= instruction(31 downto 26);
							shamt <= instruction(10 downto 6);
							funct <= instruction(5 downto 0);
							memory_read <= '0';
							memory_write <= '0';
						END IF;
					WHEN x"23" | x"2b" =>
						-- Memory instructions LW/SW.
						IF memory_target = instruction(25 downto 21) THEN
							-- No stalls but we set the line.
							memory_use_memory_buffer <= '1';
						ELSE
							-- Memory does not do forwarding in this case.
							memory_use_memory_buffer <= '0';
						END IF;
					WHEN x"04" | x"05" | x"08" =>
						-- I type instruction with sign-extension.
						IF execute_target = instruction(25 downto 21) THEN
							-- The execut
							stall_counter := 2;
							opcode <= "000000";
							target <= "00000";
							memory_read <= '0';
							memory_write <= '0';
						ELSIF memory_target = instruction(25 downto 21) THEN
							stall_counter := 2;
							opcode <= "000000";
							target <= "00000";
							memory_read <= '0';
							memory_write <= '0';
						ELSE
							opcode <= instruction(31 downto 26);
							read_data_1 <= register_file(to_integer(unsigned(instruction(25 downto 21))));
							target <= instruction(20 downto 16);
							immediate <= std_logic_vector(resize(signed(instruction(15 downto 0)), 32));
							memory_read <= '0';
							memory_write <= '0';
						END IF;
					WHEN x"0a" | x"0c" | x"0d" | "00001110" =>
						-- I type instruction with zero-extension.
						IF execute_target = instruction(25 downto 21) THEN
							-- The execut
							stall_counter := 2;
							opcode <= "000000";
							target <= "00000";
							memory_read <= '0';
							memory_write <= '0';
						ELSIF memory_target = instruction(25 downto 21) THEN
							stall_counter := 2;
							opcode <= "000000";
							target <= "00000";
							memory_read <= '0';
							memory_write <= '0';
						ELSE
							opcode <= instruction(31 downto 26);
							read_data_1 <= register_file(to_integer(unsigned(instruction(25 downto 21))));
							target <= instruction(20 downto 16);
							immediate <= x"0000" & instruction(15 downto 0);
							IF opcode_v = x"2b" THEN
								memory_read <= '1';
								memory_write <= '0';
							ELSIF opcode_v = x"23" THEN
								memory_read <= '0';
								memory_write <= '1';
							ELSE
								memory_read <= '0';
								memory_write <= '0';
							END IF;
								
						END IF;
					WHEN x"02" | x"03" =>
						-- J type instruction.
						opcode <= instruction(31 downto 26);
						immediate <= std_logic_vector(resize(unsigned(instruction(25 downto 0)), 32));
					WHEN OTHERS =>
						REPORT "case error" SEVERITY FAILURE;
				END CASE;
			ELSE
				-- Reduce the stall count.
				stall_counter := stall_counter - 1;
				IF stall_counter = 0 THEN
					stall_fetch <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END decode_arch;
