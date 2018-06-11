library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexer_2_1_data is
	port(in0, in1: in std_logic_vector(15 downto 0);
				s : in std_logic;
				z : out std_logic_vector(15 downto 0));
end multiplexer_2_1_data;

architecture comb of multiplexer_2_1_data is
begin
		z <= 	in0 when s = '0' else
					in1 when s = '1' else
					(others => 'X');

end comb;