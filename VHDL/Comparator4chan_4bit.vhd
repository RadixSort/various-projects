LIBRARY 	ieee;
USE 		ieee.std_logic_1164.all;
USE 		IEEE.NUMERIC_STD.ALL ;		-- include because we use UNSIGNED below


ENTITY Comparator4chan_4bit IS
	PORT(
	   	A, B, C, D				: in unsigned(3 downto 0) ; 			-- 4, 4 bit inputs
	   	Led1, Led2, Led3		: out std_logic 										-- single bit output to LEDs
   );
END;

ARCHITECTURE Behavioural OF Comparator4chan_4bit IS
BEGIN
	PROCESS(A, B, C, D) 						-- process sensitive to changes in these signals
	BEGIN
	
Led1 <= '0';
Led2 <= '0';
Led3 <= '0';
		
   if (A = B and B = C and C = D )
		then Led1 <= '1';
	elsif ( (A > B) and (A > C) and (A = D) )
		then Led2 <= '1';
	elsif ( (A <= B) or ((A < C) and (A = (NOT D) )))
		then Led3 <= '1';
	end if;
		
	END PROCESS ;													-- end of the process
END;