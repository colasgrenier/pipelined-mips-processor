library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY write_back IS
    PORT (
        mux_select      : in std_logic;
        memory_result   : in std_logic_vector(31 downto 0);
        alu_result      : in std_logic_vector(31 downto 0);
        mux_output      : out std_logic_vector(31 downto 0)
    );
END write_back;

architecture wb of write_back is

component MUX is
port(
	one_in : in std_logic_vector (31 downto 0);
	zero_in : in std_logic_vector (31 downto 0);
	mux_select : in std_logic;
	mux_out : out std_logic_vector (31 downto 0)
);
end component;

begin

  wb_mux : MUX
	   port map(
		    one_in => memory_result,
		    zero_in => alu_result,
		    mux_select => mux_select,
		    mux_out => mux_output
	   );
end wb;



