LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Mux2Chan_4bit IS
	PORT(
	   	InA, InB			: in std_logic_vector(3 downto 0) ; 			-- 2, 4 bit inputs
	   	Output			: out std_logic_vector(3 downto 0) ; 			-- 4 bit output
						
			ChanSelect    	: in std_logic											-- channel select input: 1 bit to select 1 of 2 channels
       );
END;

ARCHITECTURE Behavioural OF Mux2Chan_4bit IS
BEGIN
	PROCESS(InA, InB, ChanSelect) 						-- process sensitive to changes in these signals
	BEGIN

		IF(ChanSelect = '0')	THEN
			Output <= InB;
		ELSE
			Output <= InA;
		-- write your code here when ChanSelect = 1
		
		END IF ;

	END PROCESS ;													-- end of the process
END;