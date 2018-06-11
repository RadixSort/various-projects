LIBRARY 		IEEE ;
USE			IEEE.STD_LOGIC_1164.ALL ;
USE			IEEE.NUMERIC_STD.ALL ;
 
ENTITY   CLOCK_TIMER    IS
	PORT (	
		Clock , Play, Fast, Faster               	:   IN     STD_LOGIC ;
		Done	         									:   OUT    STD_LOGIC 				
	) ;
END ;
 
ARCHITECTURE   Behavioural   OF   CLOCK_TIMER   IS
	SIGNAL    Count    :    UNSIGNED  ( 25 DOWNTO  0 ) ;
	BEGIN
    	PROCESS( Clock )
    	BEGIN
	
		IF ( rising_edge ( Clock ) )  THEN
			
			IF ( Play =  '1' AND Fast = '0' AND Faster = '0'  )  THEN
		   	Count  <=  "10111110101111000010000001";
							IF ( Count  >   0  ) THEN						
					Count  <=  Count  -  1 ;
					END IF;
					
			ELSIF ( Play =  '0' AND Fast = '1' AND Faster = '0'  ) THEN
		      Count  <=  "00100110001001011010000000";
							IF ( Count  >   0  ) THEN						
					Count  <=  Count  -  1 ;
					END IF;
					
			ELSIF ( Play =  '0' AND Fast = '0' AND Faster = '1'  ) THEN
				Count  <=  "00000001111010000100100000";						
		        			IF ( Count  >   0  ) THEN						
					Count  <=  Count  -  1 ;
					END IF;
		END  IF ;
	END  IF ;
END PROCESS ;
		
	PROCESS( Count )
	BEGIN
		IF ( Count  =  0  )  THEN
		Done  <=  '1' ;
		ELSE                					
		Done  <=  '0' ;
		END IF ;
	END PROCESS ;
END ;
