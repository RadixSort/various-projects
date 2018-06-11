LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HexDisplayDriver IS
	PORT(
	   	Inputs_DCBA 			: in std_logic_vector(3 downto 0) ; 	-- inputs A,B,C,D = slider switches SW[0], SW[1], SW[2], SW[3] respectively
	   	Segments_g_to_a 		: out std_logic_vector(6 downto 0)  	-- outputs a,b,c,d,e,f,g = Hex display HEX0 (right most 7 segement display on the Altera DE Board
       );
END;

ARCHITECTURE Behavioural OF HexDisplayDriver IS
BEGIN
	PROCESS(Inputs_DCBA) 						-- process sensitive to changes in these signals
	BEGIN

-- describe how the values of ABCD in range {0000 – 1111}, i.e. 0 - F in Hex
-- map to abcdefg using if-else statements etc

		if(Inputs_DCBA = "0000") then
			Segments_g_to_a <= "1000000"; 		-- fill in the required 7 bit value between the quotes, currently all 7 segments turned ON when DCBA = 0000
		
		elsif(Inputs_DCBA = "0001") then
			Segments_g_to_a <= "1111001"; -- 
		
		elsif(Inputs_DCBA = "0010") then
			Segments_g_to_a <= "0100100"; 
		
		elsif(Inputs_DCBA = "0011") then
			Segments_g_to_a <= "0110000";
		
		elsif(Inputs_DCBA = "0100") then
			Segments_g_to_a <= "0011001";
			
		elsif(Inputs_DCBA = "0101") then
			Segments_g_to_a <= "0010010";
			
		elsif(Inputs_DCBA = "0110") then
			Segments_g_to_a <= "0000010";
			
		elsif(Inputs_DCBA = "0111") then
			Segments_g_to_a <= "1111000";
		
		elsif(Inputs_DCBA = "1000") then
			Segments_g_to_a <= "0000000";
		
		elsif(Inputs_DCBA = "1001") then
			Segments_g_to_a <= "0010000";
			
		elsif(Inputs_DCBA = "1010") then
			Segments_g_to_a <= "0001000";
			
		elsif(Inputs_DCBA = "1011") then
			Segments_g_to_a <= "0000011";
		
		elsif(Inputs_DCBA = "1100") then
			Segments_g_to_a <= "1000110";
		
		elsif(Inputs_DCBA = "1101") then
			Segments_g_to_a <= "0100001";
		
		elsif(Inputs_DCBA = "1110") then
			Segments_g_to_a <= "0000110";
		
		else												-- if inputs = 1111
			Segments_g_to_a <= "0001110"; 		-- fill in the required 7 bit value between the quotes, currently all 7 segments turned OFF when DCBA NOT EQUAL to 0000
		end if ;	

	END PROCESS ;									-- end of the process
END;
