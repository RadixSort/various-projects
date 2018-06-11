library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexer_2_1 is
	port(in0, in1: in std_logic;
				s : in std_logic;
				z : out std_logic);
end multiplexer_2_1;

architecture comb of multiplexer_2_1 is
begin
	z <= 	in0 when s = '0' else
				in1 when s = '1'else
				'X'; 
end comb;