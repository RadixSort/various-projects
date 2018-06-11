LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY TAPE_COUNTER IS 
	
	PORT(
		Clock, Reset, Increment, Decrement:  		IN Std_logic;
				 Second:										OUT Unsigned (3 downto 0);
				 Decisecond:								OUT Unsigned (3 downto 0);
				 Minute:										OUT Unsigned (3 downto 0);
				 Deciminute:								OUT Unsigned (3 downto 0);
				 Hour:										OUT Unsigned (3 downto 0);
				 Decihour:									OUT Unsigned (3 downto 0)
		) ;
END ;

ARCHITECTURE BLEEPBLOOP OF TAPE_COUNTER IS
		SIGNAL 		CountSecond: Unsigned (3 downto 0);
		SIGNAL		CountDecisecond: Unsigned (3 downto 0);
		SIGNAL 		CountMinute: Unsigned (3 downto 0);
		SIGNAL		CountDeciminute: Unsigned (3 downto 0);
		SIGNAL 		CountHour: Unsigned (3 downto 0);
		SIGNAL 		CountDecihour: Unsigned (3 downto 0);
		
BEGIN
		PROCESS(Clock)
		BEGIN
			IF(rising_edge(Clock)) THEN
				IF ( Reset = '1' ) THEN
					CountDeciSecond <= "0000";
					CountDecihour <= "0000";
					CountDeciminute <= "0000";
					CountHour <= "0000";
					CountMinute <= "0000";
					CountSecond <= "0000";
				
				ELSIF ( Increment = '1' AND Decrement = '0' ) THEN
					
					IF ( ( CountDecihour = "1001" ) AND ( CountHour = "1001" )  AND ( CountDeciminute = "0101" ) AND ( CountMinute = "1001" ) AND ( CountDeciSecond = "0101" ) AND ( CountSecond = "1001" ) ) THEN
						CountDecihour <= "0000";
						CountHour <= "0000";
						CountDeciminute <= "0000";
						CountMinute <= "0000";
						CountDeciSecond <= "0000";
						CountSecond <= "0000";
						
					ELSIF ( ( CountHour = "1001" ) AND ( CountDeciminute = "0101" ) AND ( CountMinute = "1001" ) AND ( CountDeciSecond = "0101" ) AND ( CountSecond = "1001" )) THEN
						CountDecihour <= CountDecihour + 1;
						CountHour <= "0000";
						CountDeciminute <= "0000";
						CountMinute <= "0000";
						CountDeciSecond <= "0000";
						CountSecond <= "0000";
						
					ELSIF ( ( CountDeciminute = "0101" ) AND ( CountMinute = "1001" ) AND ( CountDeciSecond = "0101" ) AND ( CountSecond = "1001" )) THEN
						CountHour <= CountHour + 1;
						CountDeciminute <= "0000";
						CountMinute <= "0000";
						CountDeciSecond <= "0000";
						CountSecond <= "0000";
						
					ELSIF ( ( CountMinute = "1001" ) AND ( CountDeciSecond = "0101" ) AND ( CountSecond = "1001" ) ) THEN
						CountDeciminute <= CountDeciminute + 1;
						CountMinute <= "0000";
						CountDeciSecond <= "0000";
						CountSecond <= "0000";
						
					ELSIF ( ( CountDeciSecond = "0101" ) AND ( CountSecond = "1001" ) ) THEN
						CountMinute <= CountMinute + 1;
						CountDecisecond <= "0000";
						CountSecond <= "0000";
						
					ELSIF ( CountSecond = "1001" ) THEN
						CountDecisecond <= CountDecisecond + 1;
						CountSecond <= "0000";

					ELSE
						CountSecond <= CountSecond + 1;
						
					END IF;
					
				ELSIF ( Increment = '0' AND Decrement = '1' ) THEN

					IF ( ( CountSecond = "0000" ) AND ( CountDeciSecond = "0000" ) AND ( CountMinute = "0000" ) AND ( CountDeciminute = "0000" ) AND ( CountHour = "0000" ) AND NOT( CountDecihour = "0000" ) ) THEN
						CountDecihour <= CountDecihour - 1;
						CountHour <= "1001";
						CountDeciminute <= "0101";
						CountMinute <= "1001";
						CountDecisecond <= "0101";
						CountSecond <= "1001";
						
					ELSIF ( ( CountSecond = "0000" ) AND ( CountDeciSecond = "0000" ) AND ( CountMinute = "0000" ) AND ( CountDeciminute = "0000" ) AND NOT( CountHour = "0000" ) ) THEN
						CountHour <= CountHour - 1;
						CountDeciminute <= "0101";
						CountMinute <= "1001";
						CountDecisecond <= "0101";
						CountSecond <= "1001";
						
					ELSIF ( ( CountSecond = "0000" ) AND ( CountDeciSecond = "0000" ) AND ( CountMinute = "0000" ) AND NOT( CountDeciminute = "0000" ) ) THEN 
						CountDeciminute <= CountDeciminute - 1;
						CountMinute <= "1001";
						CountDecisecond <= "0101";
						CountSecond <= "1001";
					
					ELSIF ( ( CountSecond = "0000" ) AND ( CountDeciSecond = "0000" ) AND NOT( CountMinute = "0000" ) ) THEN 
						CountMinute <= CountMinute - 1;
						CountDecisecond <= "0101";
						CountSecond <= "1001";
						
					ELSIF ( ( CountSecond = "0000" ) AND NOT( CountDeciSecond = "0000" ) ) THEN 
						CountDeciSecond <= CountDeciSecond - 1;
						
							CountSecond <= "1001";
				ELSIF ( ( CountSecond = "0000" ) AND ( CountDeciSecond = "0000" ) AND ( CountMinute = "0000" ) AND ( CountDeciminute = "0000" ) AND( CountHour = "0000" ) AND ( CountDecihour = "0000" ) ) THEN 
						CountSecond <= "0000";
						
					ELSE 
						CountSecond <= CountSecond - 1;
						
					END IF;
				
				END IF;
				
			END IF;
			
			Second <= CountSecond;
			Decisecond <= CountDecisecond;
			Minute <= CountMinute;
			Deciminute <= CountDeciminute;
			Hour <= CountHour;
			Decihour <= CountDecihour;
			
		END PROCESS;
END;
				