library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY fetch IS
	PORT (
		clock		: in std_logic;				-- clock signal.
		branch		: in std_logic;				-- determines whether to branch for the computed address.
		branch_address	: in std_logic_vector(31 downto 0);	-- computed address for branch.
		instruction	: out std_logic_vector(31 downto 0);	-- instruction that was read.
	);
END ENTITY;

ENTITY instruction_memory IS
	PORT (
		clock	: in std_logic;
		read	: in std_logic;
		address	: in std_logic_vector(31 downto 0);
		output	: out std_logic_vector(31 downto 0);
		wait	: out std_logic;
	);
END ENTITY;

ARCHITECTURE fetch_arch OF fetch IS

BEGIN

END fetch_arch;
