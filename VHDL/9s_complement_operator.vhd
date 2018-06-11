LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Nines_Compliment_Circuit IS
	PORT(
	   	Inputs_Binary 			: in std_logic_vector(3 downto 0) ; 	
	   	Output_Nines_Comp 		: out std_logic_vector(3 downto 0) 
       );
END;

ARCHITECTURE Behavioural OF Nines_Compliment_Circuit IS
BEGIN
	PROCESS(Inputs_Binary) 						
	BEGIN
	
		if(Inputs_Binary = "0000") then
			Output_Nines_Comp <= "1001";
			
		elsif(Inputs_Binary = "0001") then
			Output_Nines_Comp <= "1000"; 
		
		elsif(Inputs_Binary = "0010") then
			Output_Nines_Comp <= "0111"; 		
		
		elsif(Inputs_Binary = "0011") then
			Output_Nines_Comp <= "0110";
			
		elsif(Inputs_Binary = "0100") then
			Output_Nines_Comp <= "0101";
			
		elsif(Inputs_Binary = "0101") then
			Output_Nines_Comp <= "0100";
			
		elsif(Inputs_Binary = "0110") then
			Output_Nines_Comp <= "0011";
			
		elsif(Inputs_Binary = "0111") then
			Output_Nines_Comp <= "0010";
			
		elsif(Inputs_Binary = "1000") then
			Output_Nines_Comp <= "0001";
			
		else												
			Output_Nines_Comp <= "0000"; 		
		end if ;	

	END PROCESS ;					
END;
