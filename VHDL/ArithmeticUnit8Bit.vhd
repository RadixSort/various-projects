LIBRARY 	ieee;
USE 		ieee.std_logic_1164.all;
USE 		IEEE.NUMERIC_STD.ALL ;			-- include because we use UNSIGNED below


ENTITY ArithmeticUnit8Bit IS
	PORT(
	   	A, B				 : in unsigned(7 downto 0) ; 				-- 2 x 8 bit operands
			OperationSelect : in std_logic_vector(1 downto 0); 	-- 2 bit to decide which of 4 operator to perform
			Result			 : out unsigned(7 downto 0) 				-- an 8 bit result
   );
END;

ARCHITECTURE Behavioural OF ArithmeticUnit8Bit IS
BEGIN
	PROCESS(A, B, OperationSelect) 						-- process sensitive to changes in these signals
	BEGIN
	
	IF (OperationSelect = "00") THEN
		Result <= A+B;
	ELSIF (OperationSelect = "01") THEN
		Result <= A-B;
	ELSIF (OperationSelect = "10") THEN
		Result <= A and B;
	ELSIF (OperationSelect = "11") THEN
		Result <= A or B;
	END IF;
	-- write your code for the arithmetic operation here
		
	END PROCESS ;													-- end of the process
END;