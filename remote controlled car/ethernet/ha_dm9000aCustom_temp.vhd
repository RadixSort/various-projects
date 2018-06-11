
library ieee;
use ieee.std_logic_1164.all;
entity dm9000a is 
  port(
		signal address,read_n,write_n,chipselect_n,reset_n: in std_logic;
    signal writedata: in std_logic_vector(15 downto 0);
		signal readdata: out std_logic_vector(15 downto 0);
		signal oINT: out std_logic;
		--  DM9000A Side
    signal ENET_DATA: inout std_logic_vector(15 downto 0);
		signal ENET_CMD,
               ENET_RD_N,ENET_WR_N,
               ENET_CS_N,ENET_RST_N: out std_logic;
    signal ENET_INT: in std_logic
       );
end dm9000a;
architecture behavior of dm9000a is
begin
	ENET_DATA  <= writedata when write_n='0' else (others => 'Z');
	readdata      <= ENET_DATA;
	ENET_CMD   <= address;
	ENET_RD_N  <= read_n;
	ENET_WR_N <= write_n;
	ENET_CS_N <= chipselect_n;
	ENET_RST_N <= reset_n;
	oINT       <= ENET_INT;	
end behavior;
 
