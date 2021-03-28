library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY register_file IS
	PORT (
		clock		: in std_logic;
		read_register_1	: in std_logic_vector(4 downto 0);
		read_register_2	: in std_logic_vector(4 downto 0);
		write_register	: in std_logic_vector(4 downto 0);
		write_data	: in std_logic_vector(31 downto 0);
		read_data_1     : out std_logic_vector(31 downto 0);
		read_data_2	: out std_logic_vector(31 downto 0);
	);
END ENTITY;

ARCHITECTURE register_file_arch OF register_file IS
	-- register fi0le.
	TYPE REGISTER_FILE_CONTENTS_TYPE(31 downto 0) OF std_logic_vector(31 downto 0);
	SIGNAL register_file_contents : REGISTER_FILE_CONTENTS_TYPE;
BEGIN
	PROCESS(clock) BEGIN
		IF rising_edge(clock) THEN
			-- Write register content on the falling edge of the clock.
			-- write to register 0 if no write is to be done, since 0 is hardcoded no change will occur.
			IF write_address /= "00000" THEN
				register_file_contents(to_integer(unsigned(write_register))) <= write_data;
			END IF;
		END IF;
		IF falling_edge(clock) THEN
			-- Read register contents and give them to the execute stage on the falling edge of the clock.
			CASE opcode IS
				WHEN x"0" =>
					-- R type instruction.
					-- Place the content of RT on read_data_1 and RS on read_data_2.
					read_data_1 <= register_file_contents(to_integer(unsigned(read_register_1)));
					read_data_2 <= register_file_contents(to_integer(unsigned(read_register_2)));
				WHEN =>
					-- I type instruction with zero-padded immediate value.
					-- Place the content of Rt on read_data_1.
					-- TODO: determine what to do with read_data_2 (set to 0?).
					read_data_1 <= register_file_contents(to_integer(unsigned(read_register_1)));
					read_data_2 <= register_file_contents(to_integer(unsigned(read_register_2)));
					immediate <= x"00000000" & ();
				WHEN =>
					-- I type instruction with zero-padded immediate value.
					-- Place the content of Rt on read_data_1.
					-- TODO: determine what to do with read_data_2 (set to 0?).
					read_data_1 <= register_file_contents(to_integer(unsigned(read_register_1)));
					read_data_2 <= register_file_contents(to_integer(unsigned(read_register_2)));
					-- Sign extension.
					IF i(15) = '1' THEN
						immediate <= x"FFFF0000" & ();
					ELSE
						immediate <= x"00000000" & ();
					END IF;
				WHEN =>
					-- J type instruction.
					-- why would we shift and why 16 bits of the diagram?
			END CASE:
		END IF;
	END PROCESS;
END register_file_arch;
