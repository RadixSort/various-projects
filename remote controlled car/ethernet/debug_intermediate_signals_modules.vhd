library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity debug_intermediate_signals_modules is
	port(
	
			RXbuffer0: in std_logic_vector(15 downto 0);
			RXbuffer1: in std_logic_vector(15 downto 0);
			RXbuffer2: in std_logic_vector(15 downto 0);
			RXbuffer3: in std_logic_vector(15 downto 0);
			RXbuffer4: in std_logic_vector(15 downto 0);
			RXbuffer5: in std_logic_vector(15 downto 0);
			RXbuffer6: in std_logic_vector(15 downto 0);
			RXbuffer01: in std_logic_vector(15 downto 0);
			RXbuffer11: in std_logic_vector(15 downto 0);
			RXbuffer21: in std_logic_vector(15 downto 0);
			RXbuffer31: in std_logic_vector(15 downto 0);
			RXbuffer41: in std_logic_vector(15 downto 0);
			RXbuffer51: in std_logic_vector(15 downto 0);
			RXbuffer61: in std_logic_vector(15 downto 0);
			messageCounter:in integer;
			stateCounter: in std_logic_vector(5 downto 0);
			timeHwRead:out std_logic_vector(31 downto 0);
			timeSwHwRead:out std_logic_vector(31 downto 0);
			clk: in std_logic
	 );
end debug_intermediate_signals_modules;

architecture behavior of debug_intermediate_signals_modules is
signal timeHwRead_inter:std_logic_vector(31 downto 0):=(others=>'0');
signal timeSwHwRead_inter:std_logic_vector(31 downto 0):=(others=>'0');


begin


timeHwRead<=timeHwRead_inter;
timeSwHwRead<=timeSwHwRead_inter;
process(clk)
	begin
	IF (clk'EVENT and clk = '1') then
	
		if(stateCounter="000001") then
			timeHwRead_inter<=(others => '0');
			timeSwHwRead_inter<=(others => '0');
		end if;
		

		if(stateCounter>="000010" and stateCounter<="100111") then
				timeHwRead_inter<=timeHwRead_inter+1;
		end if;
		

		if(stateCounter>="000010" and stateCounter<="101001") then
				timeSwHwRead_inter<=timeSwHwRead_inter+1;
		end if;
		
	end if;
end process;

end behavior;