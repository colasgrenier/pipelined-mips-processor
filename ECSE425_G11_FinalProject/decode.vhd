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
		memory_read			: out std_logic;
		memory_write			: out std_logic;
		execute_1_use_execute		: out std_logic;
		execute_2_use_execute		: out std_logic;
		execute_1_use_memory		: out std_logic;
		execute_2_use_memory		: out std_logic;
		memory_use_memory		: out std_logic;
		memory_use_writeback		: out std_logic
	);
END decode;
	
ARCHITECTURE decode_arch of decode IS
	TYPE register_file_content_type IS ARRAY(31 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL register_file				: register_file_content_type;
	SIGNAL execute_target				: std_logic_vector(4 downto 0) := "00000";		-- The target of the execute stage.
	SIGNAL writeback_target				: std_logic_vector(4 downto 0) := "00000";
	SIGNAL memory_target				: std_logic_vector(4 downto 0) := "00000";		-- The target of the instruction presently in the memory stage
	SIGNAL stalling					: std_logic := '0';
	SIGNAL opcode_buffer				: std_logic_vector(5 downto 0);
	SIGNAL funct_buffer				: std_logic_vector(5 downto 0);
	SIGNAL shamt_buffer				: std_logic_vector(4 downto 0);
	SIGNAL immediate_buffer				: std_logic_vector(31 downto 0);
	SIGNAL execute_result_available_execute		: std_logic := '0';				-- Whether the instruction presently in the execute stage will have its result available in the execute stage.
	SIGNAL execute_1_use_execute_buffer		: std_logic := '0';
	SIGNAL execute_2_use_execute_buffer		: std_logic := '0';
	SIGNAL execute_1_use_memory_buffer		: std_logic := '0';
	SIGNAL execute_2_use_memory_buffer		: std_logic := '0';
	SIGNAL memory_use_memory_delayed_buffer		: std_logic := '0';				-- Buffer to hold the signal indicating to the memory stage to use the previous result of the memory stage (fowarding).
	SIGNAL memory_use_memory_current_buffer		: std_logic := '0';
	SIGNAL memory_use_writeback_delayed_buffer	: std_logic := '0';
	SIGNAL memory_use_writeback_current_buffer	: std_logic := '0';
	SIGNAL memory_read_delayed_buffer		: std_logic := '0';
	SIGNAL memory_write_delayed_buffer		: std_logic := '0';
	SIGNAL memory_read_current_buffer		: std_logic := '0';
	SIGNAL memory_write_current_buffer		: std_logic := '0';
	SIGNAL read_data_1_address			: std_logic_vector(4 downto 0);
	SIGNAL read_data_2_address			: std_logic_vector(4 downto 0);
	SIGNAL read_data_1_buffer			: std_logic_vector(31 downto 0);
	SIGNAL read_data_2_buffer			: std_logic_vector(31 downto 0);
BEGIN
	PROCESS(
		stalling,
		opcode_buffer,
		funct_buffer,
		shamt_buffer,
		immediate_buffer,
		execute_1_use_execute_buffer,
		execute_2_use_execute_buffer,
		execute_1_use_memory_buffer,
		execute_2_use_memory_buffer,
		memory_use_memory_current_buffer,
		memory_use_writeback_current_buffer,
		memory_read_current_buffer,
		memory_write_current_buffer,
		read_data_1_buffer,
		read_data_2_buffer
	) BEGIN
		IF stalling = '1' THEN
			opcode <= "000000";
			funct <= "000000";			
			shamt <= "00000";
			immediate <= x"00000000";
			execute_1_use_execute <= '0';
			execute_2_use_execute <= '0';
			execute_1_use_memory <= '0';
			execute_2_use_memory <= '0';
			memory_use_memory <= memory_use_memory_current_buffer;
			memory_use_writeback <= memory_use_writeback_current_buffer;
			memory_read <= memory_read_current_buffer;
			memory_write <= memory_write_current_buffer;
			read_data_1 <= x"00000000";
			read_data_2 <= x"00000000";
		ELSE
			opcode <= opcode_buffer;
			funct <= funct_buffer;
			shamt <= shamt_buffer;
			immediate <= immediate_buffer;
			execute_1_use_execute <= execute_1_use_execute_buffer;
			execute_2_use_execute <= execute_2_use_execute_buffer;
			execute_1_use_memory <= execute_1_use_memory_buffer;
			execute_2_use_memory <= execute_2_use_memory_buffer;
			memory_use_memory <= memory_use_memory_current_buffer;
			memory_use_writeback <= memory_use_writeback_current_buffer;
			memory_read <= memory_read_current_buffer;
			memory_write <= memory_write_current_buffer;
			read_data_1 <= read_data_1_buffer;
			read_data_2 <= read_data_2_buffer;
		END IF;
	END PROCESS;
	PROCESS (clock)
		VARIABLE stall_counter			: integer := 0;	
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
				REPORT "writing to register " & integer'image(to_integer(unsigned(writeback_target))) & 
				" value " & integer'image(to_integer(signed(write_data)));
				register_file(to_integer(unsigned(writeback_target))) <= write_data;
			END IF;
		END IF;
		-- We process the instruction, check for hazards, etc. on the rising edge.
		IF rising_edge(clock) THEN
			-- The executions move by one.
			writeback_target <= memory_target;
			memory_target <= execute_target;
			-- Shift the buffers.
			memory_use_memory_current_buffer <= memory_use_memory_delayed_buffer;
			memory_use_writeback_current_buffer <= memory_use_writeback_delayed_buffer;
			memory_write_current_buffer <= memory_write_delayed_buffer;
			memory_read_current_buffer <= memory_read_delayed_buffer;
			--
			execute_target <= "00000";
			IF stalling = '1' THEN
				-- We are stalling.
				IF stall_counter > 1 THEN
					stall_counter := stall_counter - 1;
				ELSE
					-- Stall counter is 1.
					stalling <= '0';
					stall_counter := 0;
					stall_fetch <= '0';
				END IF;
				execute_target <= "00000";
				memory_use_memory_delayed_buffer <= '0';
				memory_use_writeback_delayed_buffer <= '0';
			ELSE
				-- We are not stalling, check for dependencies.
				-- Sets signals for hazards/stalling/fowarding.
				opcode_v := "00" & instruction(31 downto 26);
				-- Check for dependencies & set signals appropriately.
				CASE opcode_v IS
					WHEN x"00" =>
						-- R type instructions
						REPORT "decode: r-instruction funct " & integer'image(to_integer(unsigned(opcode_v))) & " rs=" & integer'image(to_integer(unsigned(instruction(25 downto 21)))) & " rt=" & integer'image(to_integer(unsigned(instruction(20 downto 15)))) & " rd=" & integer'image(to_integer(unsigned(instruction(15 downto 11))));
						IF (execute_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000") OR (execute_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000") THEN
							-- The execute stage is computing a result that will be written to one of the read register.
							REPORT "    instr in exec will write to read register";	
							IF execute_result_available_execute = '1' THEN
								-- The result will be immediately available as the result of the execute stage.
								-- Stalling is not necessary.
								IF execute_target = instruction(25 downto 21) THEN
									-- The execute stages computes a value that will be written to RS.
									execute_1_use_execute_buffer <= '1';
									execute_2_use_execute_buffer <= '0';
								ELSE
									-- The execute stages computes a value that will be written to RT.
									execute_1_use_execute_buffer <= '0';
									execute_2_use_execute_buffer <= '1';
								END IF;
								execute_1_use_memory_buffer <= '0';
								execute_2_use_memory_buffer <= '0';
							ELSE
								-- The result will only be available as the result of the memory stage.
								-- We need to stall for one cycle.
								stall_counter := 1;
								stalling <= '1';
								stall_fetch <= '1';
								IF execute_target = instruction(25 downto 21) THEN
									execute_1_use_memory_buffer <= '1';
									execute_2_use_memory_buffer <= '0';
								ELSE
									execute_1_use_memory_buffer <= '0';
									execute_2_use_memory_buffer <= '1';
								END IF;
								execute_1_use_execute_buffer <= '0';
								execute_2_use_execute_buffer <= '0';
							END IF;
							-- No signal to memory.
							memory_use_memory_delayed_buffer <= '0';
							memory_use_writeback_delayed_buffer <= '0';
						ELSIF (memory_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000") OR (memory_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000") THEN
							-- If the memory stage will write to one of the read registers, stall for one cycle.
							REPORT "    memory stage will write to one of the read registers";
							IF memory_target = instruction(25 downto 21) THEN
								execute_1_use_memory_buffer <= '1';
								execute_2_use_memory_buffer <= '0';
							ELSE
								execute_1_use_memory_buffer <= '0';
								execute_2_use_memory_buffer <= '1';
							END IF;
							execute_1_use_execute_buffer <= '0';
							execute_2_use_execute_buffer <= '0';
						ELSE
							execute_1_use_execute_buffer <= '0';
							execute_2_use_execute_buffer <= '0';
							execute_1_use_memory_buffer <= '0';
							execute_2_use_memory_buffer <= '0';
						END IF;
						execute_result_available_execute <= '1';
						memory_read_delayed_buffer <= '0';
						memory_write_delayed_buffer <= '0';
						memory_use_memory_delayed_buffer <= '0';
						memory_use_writeback_delayed_buffer <= '0';
						read_data_1_address <= instruction(25 downto 21);
						read_data_2_address <= instruction(20 downto 16);
						execute_target <= instruction(15 downto 11);
						opcode_buffer <= instruction(31 downto 26);
						shamt_buffer <= instruction(10 downto 6);
						funct_buffer <= instruction(5 downto 0);
						immediate_buffer <= std_logic_vector(resize(signed(instruction(25 downto 0)), 32));
					WHEN x"23" | x"2b" =>
						-- Load instruction.
						REPORT "decode: load";
						-- We check for hazards and set fowarding for RS.
						IF (execute_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000") THEN
							-- The execute stage is currently processing and instruction which will write to RS,
							-- which this instruction will read.
							IF execute_result_available_execute = '1' THEN
								-- The RS register is available right away (it is being computed by the ALU as this moment).
								execute_1_use_execute_buffer <= '1';
								execute_1_use_memory_buffer <= '0';
							ELSE
								-- The value of the RS register is not available right now.
								-- We need to stall for one cycle.
								stall_fetch <= '1';
								stall_counter := 1;
								stalling <= '1';
								execute_1_use_execute_buffer <= '0';
								execute_1_use_memory_buffer <= '1';						
							END IF;
						ELSIF (memory_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000") THEN
							-- The memory stage is currently processing and instruction which will write to RS,
							-- which this instruction will read.
							execute_1_use_execute_buffer <= '0';
							execute_1_use_memory_buffer <= '1';
						ELSE
							-- No hazards or fowarding whatsoever for RS.
							execute_1_use_execute_buffer <= '0';
							execute_1_use_memory_buffer <= '0';
						END IF;
						-- We check for hazards and fowarding for RT is the instruction is store.
						IF opcode_v = x"2b" THEN
							-- Store instruction.
							IF (execute_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000") THEN
								IF execute_result_available_execute = '1' THEN
									-- The result of the instruction in the execute stage are available right away.
									execute_2_use_execute_buffer <= '1';
									execute_2_use_memory_buffer <= '0';
									memory_use_memory_delayed_buffer <= '0';
								ELSE
									-- The result will only be available in the memory stage.
									execute_2_use_execute_buffer <= '0';
									execute_2_use_memory_buffer <= '0';
									memory_use_memory_delayed_buffer <= '1';
								END IF;
							ELSIF (memory_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000") THEN
								execute_2_use_execute_buffer <= '0';
								execute_2_use_memory_buffer <= '1';
								memory_use_memory_delayed_buffer <= '0';
							ELSE
								execute_2_use_execute_buffer <= '0';
								execute_2_use_memory_buffer <= '0';
								memory_use_memory_delayed_buffer <= '0';
							END IF;
						ELSE
							-- Load instruction, we never foward execute_2*
							execute_2_use_execute_buffer <= '0';
							execute_2_use_memory_buffer <= '0';
							memory_use_memory_delayed_buffer <= '0';
						END IF;
						-- We set the read/write signals appropriately.
						IF opcode_v = x"23" THEN
							memory_read_delayed_buffer <= '1';
							memory_write_delayed_buffer <= '0';
						ELSE
							memory_read_delayed_buffer <= '0';
							memory_write_delayed_buffer <= '1';
						END IF;
						-- The result of memory operations is not available in the execute stage.
						execute_result_available_execute <= '0';
						-- Set the target if there is one.
						IF opcode_v = x"23" THEN
							execute_target <= instruction(20 downto 16);
						ELSE
							execute_target <= "00000";
						END IF;
						-- Set other control signals.
						read_data_1_address <= instruction(25 downto 21);
						read_data_2_address <= instruction(20 downto 16);
						opcode_buffer <= instruction(31 downto 26);
						shamt_buffer <= "00000";
						funct_buffer <= "000000";
						immediate_buffer <= std_logic_vector(resize(signed(instruction(15 downto 0)), 32));
					WHEN x"04" | x"05" | x"08" | x"0a" | x"0c" | x"0d" | x"0e" | x"0f" =>
						-- I type instruction .
						REPORT "i instruction with sign-extension";
						IF opcode_v = x"04" THEN
							REPORT " x04 BEQ";
						ELSIF opcode_v = x"05" THEN
							REPORT " x05 BNE";
						END IF;
						IF execute_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000" THEN
							REPORT "    execute use execute";
							IF execute_result_available_execute = '1' THEN
								execute_1_use_execute_buffer <= '1';
								execute_1_use_memory_buffer <= '0';
							ELSE
								-- stall stall stall baby
								stall_fetch <= '1';
								stall_counter := 1;
								stalling <= '1';
								execute_1_use_execute_buffer <= '0';
								execute_1_use_memory_buffer <= '1';
							END IF;
						ELSIF memory_target = instruction(25 downto 21) AND instruction(25 downto 21) /= "00000" THEN
							execute_1_use_execute_buffer <= '0';
							execute_1_use_memory_buffer <= '1';
						ELSE
							execute_1_use_execute_buffer <= '0';
							execute_1_use_memory_buffer <= '0';
						END IF;
						IF opcode_v = x"05" OR opcode_v = x"04" THEN
							IF execute_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000" THEN
								REPORT "    execute use execute";
								IF execute_result_available_execute = '1' THEN
									execute_2_use_execute_buffer <= '1';
									execute_2_use_memory_buffer <= '0';
								ELSE
									-- stall stall stall baby
									stall_fetch <= '1';
									stall_counter := 1;
									stalling <= '1';
									execute_2_use_execute_buffer <= '0';
									execute_2_use_memory_buffer <= '1';
								END IF;
							ELSIF memory_target = instruction(20 downto 16) AND instruction(20 downto 16) /= "00000" THEN
								execute_2_use_execute_buffer <= '0';
								execute_2_use_memory_buffer <= '1';
							ELSE
								execute_2_use_execute_buffer <= '0';
								execute_2_use_memory_buffer <= '0';
							END IF;
							execute_result_available_execute <= '0';
						ELSE
							execute_2_use_execute_buffer <= '0';
							execute_2_use_memory_buffer <= '0';
							execute_result_available_execute <= '1';
						END IF;
						read_data_1_address <= instruction(25 downto 21);
						read_data_2_address <= instruction(20 downto 16);
						IF opcode_v = x"04" OR opcode_v = x"05" THEN
							execute_target <= "00000";
						ELSE
							execute_target <= instruction(20 downto 16);
						END IF;
						opcode_buffer <= instruction(31 downto 26);
						shamt_buffer <= "00000";
						funct_buffer <= "000000";
						memory_read_delayed_buffer <= '0';
						memory_write_delayed_buffer <= '0';
						memory_use_memory_delayed_buffer <= '0';
						memory_use_writeback_delayed_buffer <= '0';
						CASE opcode_v IS
							WHEN x"04" | x"05" | x"08" =>
								immediate_buffer <= std_logic_vector(resize(signed(instruction(15 downto 0)), 32));
							WHEN  x"0a" | x"0c" | x"0d" | x"0e" | x"0f" =>
								immediate_buffer <= std_logic_vector(resize(unsigned(instruction(15 downto 0)), 32));
							WHEN OTHERS =>
								REPORT "error error 293912931233" SEVERITY FAILURE;
						END CASE;
					WHEN x"02" | x"03" =>
						REPORT "J/JR instruction";
						execute_result_available_execute <= '0';
						memory_read_delayed_buffer <= '0';
						memory_write_delayed_buffer <= '0';
						execute_1_use_execute_buffer <= '0';
						execute_2_use_execute_buffer <= '0';
						execute_1_use_memory_buffer <= '0';
						execute_2_use_memory_buffer <= '0';
						memory_use_memory_delayed_buffer <= '0';
						memory_use_writeback_delayed_buffer <= '0';
						read_data_1_address <= "00000";
						read_data_2_address <= "00000";
						immediate_buffer <= "000000" & instruction(25 downto 0);
						IF opcode_v = x"03" THEN
							execute_target <= "11111";
						ELSE
							execute_target <= "00000";
						END IF;
						opcode_buffer <= instruction(31 downto 26);
						shamt_buffer <= "00000";
						funct_buffer <= "000000";
					WHEN OTHERS =>
						REPORT "invalid opcode" SEVERITY FAILURE;
				END CASE;
			END IF;
		END IF;
		-- We read registers on the falling edge.
		IF falling_edge(clock) THEN
			read_data_1_buffer <= register_file(to_integer(unsigned(read_data_1_address)));
			read_data_2_buffer <= register_file(to_integer(unsigned(read_data_2_address)));
		END IF;
	END PROCESS;
	-- We write the registers to file whenever they change.
	PROCESS (register_file)
		FILE register_file_file			: TEXT;
		VARIABLE register_file_line		: LINE;
	BEGIN
		file_open(register_file_file, "register_file.txt", WRITE_MODE);
		FOR line IN 0 TO 31 LOOP
			write(register_file_line, register_file(line));
			writeline(register_file_file, register_file_line);
		END LOOP;
		file_close(register_file_file);
	END PROCESS;
END decode_arch;
