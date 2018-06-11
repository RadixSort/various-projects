LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY VCR IS
	PORT(
		Reset					:IN STD_LOGIC;
		Clock 				:IN STD_LOGIC;
		
	--Inputs
		Ready 				:IN STD_LOGIC;
		Done					:In STD_LOGIC;
		Stop					:IN STD_LOGIC;
		Play					:IN STD_LOGIC;
		Pause					:IN STD_LOGIC;
		Rec					:IN STD_LOGIC;
		Fwd					:IN STD_LOGIC;
		Rwd					:IN STD_LOGIC;
		TapeLoaded			:IN STD_LOGIC;
		TapeStarted			:IN STD_LOGIC;
		TapeEnded			:IN STD_LOGIC;
		Copyprotect			:IN STD_LOGIC;
		
	--Outputs
		WProtect				:OUT STD_LOGIC;
		RecSign				:OUT STD_LOGIC;
		TimerPlay			:OUT STD_LOGIC;
		TimerFast			:OUT STD_LOGIC;
		TimerFaster			:OUT STD_LOGIC;
		Msg					:OUT STD_LOGIC (3 DOWNTO 0);
		Increment			:OUT STD_LOGIC;
		Decrement			:OUT STD_LOGIC;
		TapeReset			:OUT STD_LOGIC
		);
END;

ARCHITECTURE BLEEPBLOOP OF VCR IS

		CONSTANT IDLE			: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
		CONSTANT STOP1			: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
		CONSTANT PLAY1			: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010";
		CONSTANT PAUSE1		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
		--CONSTANT REC1		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
		CONSTANT FORWARD 		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
		CONSTANT REWIND		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
		CONSTANT TAPESTART	: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
		CONSTANT TAPEEND		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
		--CONSTANT COPYWRITE	: STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";
		
		SIGNAL Next_state		: STD_LOGIC_VECTOR (3 DOWNTO 0);
		SIGNAL Current_state	: STD_LOGIC_VECTOR (3 DOWNTO 0);
		
BEGIN
	PROCESS(Clock, Reset)
		BEGIN
				if (Reset = '0') then
						Current_state <= IDLE;
				
				elsif (rising_edge (Clock)) then
						Current_state <= Next_state;
				
				end if;
	END PROCESS;
			
	PROCESS( Current_state, Stop, Play, Pause, Rec, Fwd, Rwd, TapeLoaded, TapeStarted, TapeEnded)
		BEGIN
				Next_state <= Current_state;
			
-- State	Idle	0000
-- How	Unload
-- Nxt	Stop
				if (Current_state = IDLE) then
						if(TapeLoaded = '1') then
								Next_state <= STOP1;
								
						end if;
						
-- State	Stop	0001
-- How	Load - from Idle
-- 		Stop - from All but Idle
-- Nxt	Not: Rwd, Pause
				elsif (Current_state = STOP1) then
						
						if (TapeLoaded = '0') then
							Next_state <= IDLE;
							
						elsif (TapeStarted = '1')	then 
							Next_state <= TAPESTART;
							
						elsif (TapeEnded = '1') then
							Next_state <= TAPEEND;
						
						elsif( Fwd = '1') then
							Next_state <= FORWARD;
								
						elsif(Play = '1') then
							Next_state <= PLAY1;

						end if;			
						
--	State	Play	0010
--	How	Play
--	Nxt	All
				elsif(Current_state = PLAY1) then
					
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
							
						elsif (Stop = '1') then
								Next_state <= STOP1;
								
						elsif (TapeStarted = '1') then 
								Next_state <= TAPESTART;
							
						elsif (TapeEnded = '1') then
								Next_state <= TAPEEND;
						
						elsif( Fwd = '1') then
								Next_state <= FORWARD;
								
						elsif ( Rwd = '1') then
								Next_state <= REWIND;

						elsif(Pause = '1') then
								Next_state <= PAUSE1;
					
					--	elsif (Rec = '1' AND Copyprotect = '0') then
					--		Next_state <= REC;
							
					--	elsif (Rec = '1' AND Copyprotect = '1') then
					--		Next_state <= COPYWRITE;
						
					--	elsif (Rec = '0' AND Copyprotect = '0') then
					--		Next_state <= PLAY;
						end if;
		
--	State	Pause	0011
--	How	Pause
--	Nxt	Not: TapeStart, TapeEnd
				elsif ( Current_state = PAUSE1) then
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
							
						elsif (Stop = '1') then
								Next_state <= STOP1;
						
						elsif( Fwd = '1') then
								Next_state <= FORWARD;
								
						elsif ( Rwd = '1') then
								Next_state <= REWIND;
						
						elsif(Play = '1') then
								Next_state <= PLAY1;
								
						end if;
						
--	State	Fwd	0100
--	How	Fwd button
--	Nxt	Not TapeStart
				elsif (Current_state = FORWARD) then
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
							
						elsif (Stop = '1') then
								Next_state <= STOP1;
							
						elsif (TapeEnded = '1') then
								Next_state <= TAPEEND;
						
						elsif (Rwd = '1') then
								Next_state <= REWIND;

						elsif(Pause = '1') then
								Next_state <= PAUSE1;

						elsif(Play = '1') then
								Next_state <= PLAY1;
								
						end if;
						
--	State	Rwd 	0101
--	How	Rwdbutton
--	Nxt	Not TapeEnd
				elsif (Current_state = REWIND) then
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
							
						elsif (Stop = '1') then
								Next_state <= STOP1;
								
						elsif (TapeStarted = '1') then 
								Next_state <= TAPESTART;
						
						elsif( Fwd = '1') then
								Next_state <= FORWARD;

						elsif(Pause = '1') then
								Next_state <= PAUSE1;
								
						elsif(Play = '1') then
								Next_state <= PLAY1;
						
						end if;
								
--	State	TapeEnd 	0110 - pause
--	How	TapeEnd Switch
--	Nxt	Idle, Rwd, Stop
				elsif (Current_state = TAPEEND) then
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
						
						elsif (Stop = '1') then
								Next_state <= STOP1;							
						
						elsif (Rwd = '1') then
								Next_state <= REWIND;	
								
						end if;

--State: TapeStart 0111 - Reset Timer to 00:00:00 and pause
--	How	TapeStart Switch
--			00:00:00 - then pauses
--	Nxt	Not: Rwd, TapeEnd
				elsif ( Current_state = TAPESTART)	then
						if (TapeLoaded = '0') then
								Next_state <= IDLE;
							
						elsif (Stop = '1') then
								Next_state <= STOP1;
						
						elsif( Fwd = '1') then
								Next_state <= FORWARD;

						elsif(Pause = '1') then
								Next_state <= PAUSE1;

						elsif(Play = '1') then
								Next_state <= PLAY1;
								
						end if;
					
				end if;
								
			end process;
		
	Process (Current_state)
	BEGIN
		TimerPlay <= '0' ;
		TimerFast <= '0' ;
		TimerFaster <= '0';
		Msg <= '0' ;
		Increment <='0' ;
		Decrement <='0' ;
		TapeReset <='0' ;
		WProtect <='0';
		RecSign <='0';
		
	IF (Ready = '1') then
	
		IF(Copyprotect = '1') then
				Wprotect <= '1';
		elsif(rec = '1')then
				RecSign <= '1';
		END IF;
		
		IF(Current_state = STOP1) then
				Msg <= '1';
				TapeReset <= '1';
				
		elsif(Current_state = PLAY1) then
				Msg <= '1';
				TimerPlay <= '1';
				Increment <= '1';
				
		elsif(Current_state = PAUSE1) then
				Msg <='1';
				
		elsif(Current_state = FORWARD) then
				Msg <= '1';
				TimerFast <= '1';
				Increment <= '1';
				
		elsif(Current_state = REWIND) then
				Msg <= '1';
				TimerFast <= '1';
				Decrement <= '1';
				
		elsif(Current_state = TAPESTART) then
				Msg <= '1';
				TapeReset <='1' ;
				
		elsif(Current_state = TAPEEND) then
				Msg <= '1';
		END IF;
	END IF;
end process;
end;
	