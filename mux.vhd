library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX is
port(
	one_in : in std_logic_vector (31 downto 0);
	zero_in : in std_logic_vector (31 downto 0);
	mux_select : in std_logic;
	mux_out : out std_logic_vector (31 downto 0)
);
end MUX;


architecture MUX_arch of MUX is

begin
  mux_out <= zero_in when mux_select = '0' else 
             one_in when mux_select = '0' else
             "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	
end MUX_arch;


