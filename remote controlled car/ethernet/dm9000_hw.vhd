-- DM9000 receive packet module in VHDL
-- State machine to generate control signals for read and write to registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY dm9000_hw IS

PORT(

-- inputs
	CLK,
	DONE_IOR,
	DONE_IOW,
	INIT_DONE,
	ENT_IN				: IN STD_LOGIC;
	DOUT				: IN STD_LOGIC_VECTOR(15 DOWNTO 0); 	
	RX_length: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	RX_statusIn : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	SWDoneRd : IN STD_LOGIC;

				
-- outputs	
	REG_IOR				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	Debug_RX_LEN 	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	REG_IOW				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	DATA				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	 
	READENABLE			: OUT STD_LOGIC;							-- added for new design
	WRITEENABLE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	
	EN					: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); 		-- modified for new design
	TMP_OUT				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	I_DEBUG				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	DONE_Reading_Packet : OUT STD_LOGIC;
	GP_o				: OUT STD_LOGIC;	
	CLK_OFFSET_R		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
	CLK_OFFSET_W		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
	CLK_COUNTER_R		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);	
	CLK_COUNTER_W		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);	
	
	INT_umask			: OUT STD_LOGIC;   -- s40 once unmasking of interrupts is done

-- not required for design but useful to debug
	s: BUFFER STD_LOGIC_VECTOR(5 downto 0)						

);

END dm9000_hw;


ARCHITECTURE behavior OF dm9000_hw IS

TYPE State_type IS(s00, s0, s1,s2,s3,s4,s5,if0, if1, if2, if3, if4, if5, if6, if7, if8, if9, if10, if11, es0,
					es1, es2, es3, es4, es5, es6, es7, es8, es9, es10, es11, es12, es13, es14, es15, es16, es17, es18, es19, es20, finish,s40,s41);

SIGNAL				ISR							: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"FE";
SIGNAL				IMR							: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"FF";
SIGNAL				MRCMDX						: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"F0";	
SIGNAL				MRCMD						: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"F2";
SIGNAL				NCR							: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"00";
SIGNAL				ETXCSR						: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"30";
SIGNAL				RCR							: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"05";
SIGNAL				RX_ENABLE					: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"01";
SIGNAL				PASS_MULTICAST				: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"08";
SIGNAL				RCR_Set						: STD_LOGIC_VECTOR(7 DOWNTO 0) :=  x"30";


SIGNAL  			PAR_set						: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"0080";
SIGNAL				NCR_Set						: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"0000";
SIGNAL				BPTR_Set					: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"003F";
SIGNAL				FCTR_Set					: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"005A";
SIGNAL				RTFCR_Set					: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"0029";
SIGNAL				ETXCSR_Set					: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"0083";
SIGNAL				INTR_Set					: STD_LOGIC_VECTOR(15 DOWNTO 0) :=  x"0081";


SIGNAL 				K, L, M, M_tmp, J			: BOOLEAN; 
SIGNAL 				N_S							: State_type:=s00;
SIGNAL 				GOODPACKET					: STD_LOGIC 	:= '1';
SHARED VARIABLE  	COUNT_DELAY					: INTEGER 		:= 0;
CONSTANT 			STD_DELAY					: INTEGER 		:= 10;
CONSTANT 			TEMP_DELAY					: INTEGER 		:= 10; 
SIGNAL 				RX_READY					: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL 				RX_STATUS					: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL 				RX_STATUS_TMP				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL 				RX_LEN						: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL 				I							: STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
SIGNAL				MAX_PACKET_LENGTH			: STD_LOGIC_VECTOR(15 DOWNTO 0) := x"05F2";
	
-- temp_reg and temp_data will be replaced by hardcoded register address and data 
SIGNAL 				TEMP_REG					: STD_LOGIC_VECTOR(7 DOWNTO 0);			-- dummy register address, 
SIGNAL 				TEMP_DATA					: STD_LOGIC_VECTOR(15 DOWNTO 0);	-- dummy data, just to check functionality
SIGNAL				TEMP_COUNT					: STD_LOGIC_VECTOR(10 DOWNTO 0); -- :=  x"00";
SIGNAL				TEMP_COUNT_OFF				: STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000010";

signal				debug						: std_logic; -- := '1';
signal				done_state_machine 			: std_logic		:= '0';


BEGIN
DONE_Reading_Packet <= done_state_machine;

PROCESS(clk)

BEGIN
IF rising_edge(clk) then


CASE N_S IS

			WHEN s00 => IF (INIT_DONE = '1') THEN
								N_S <= s0;					
						END IF;

			WHEN s0 =>  IF ENT_IN = '1' THEN	
										N_S <= s1; --s1;
						END IF;

			WHEN s1 => 
						REG_IOW <= IMR;	--TEMP_REG;   			-- DM9000A_IOW(IMR, PAR_SET);
						RX_STATUS <= X"0000";
						GOODPACKET <= '0';
						INT_umask <= '1';
						done_state_machine <= '0';
						
						DATA <= PAR_Set;	--TEMP_DATA;
						EN(0) <= '1';
						EN(1) <= '0';
						WRITEENABLE <= "00";
						N_S <= s1;
						TEMP_COUNT <= TEMP_COUNT + 1;							
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= s2;
						END IF;

			WHEN s2 =>  REG_IOR <= MRCMDX;	--TEMP_REG;			-- RX_READ = DM9000_IOR(MRCMDX);
						EN <= "10";
						READENABLE <= '0';
						
						TEMP_COUNT <= TEMP_COUNT + 1;
						IF DONE_IOR = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= s3;
						END IF;

			WHEN s3 =>  RX_READY <= DOUT;						-- RX_READ = IORD(BASE, IO_DATA);
						
						EN <= "10";
						READENABLE <= '0';
						--READENABLE <= '1';
						TEMP_COUNT <= TEMP_COUNT + 1;				
						IF DONE_IOR = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= s4;
						END IF;
						
			WHEN s4 =>  RX_READY <= (DOUT and x"03");						-- (JUST READ)RX_READ = IORD(BASE, IO_DATA);
						N_S <= s5;

			WHEN s5 =>  COUNT_DELAY := COUNT_DELAY + 1;
								IF(COUNT_DELAY = STD_DELAY )THEN
							
									IF (RX_READY(1) = '0' and RX_READY(0) = '1') THEN
										N_S <= if0; --s6;															-- modified for debug --
									
									ELSIF  (RX_READY(1) = '1' and RX_READY(0) = '0')  OR (RX_READY(1) = '1' and RX_READY(0) = '1') THEN
											
										N_S <= es0;	--s18;
									
									ELSIF (RX_READY(1) = '0' and RX_READY(0) = '0') THEN
										N_S <= finish; --s33;
									END IF;
									COUNT_DELAY := 0;
								END IF;
			--s6--
			WHEN if0 => REG_IOW <=	MRCMD;	--TEMP_DATA;
						EN <= "01";
						WRITEENABLE <= "10";
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= if1;--s7;
						END IF;
			--s7--
			WHEN if1 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY >= STD_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= if2; --s8;
						END IF;
			--s8--
			WHEN if2 =>  EN <= "10";
						READENABLE <= '1';
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOR = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= if3; --s9;
						END IF;
			--s9--			
			WHEN if3 =>  RX_STATUS <= RX_statusIn;
						N_S <= if4; --s10;

			--s10--
			WHEN if4 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY >= STD_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= if5; --s11;
						END IF;
			--s11--
			WHEN if5 =>  EN <= "10";
						 READENABLE <= '1';
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						
						IF DONE_IOR = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= if6; --s12;
						END IF;

			--s12--
			WHEN if6 =>     RX_LEN <= RX_length;						
									N_S <= if7; --s13;

			--s13--
			WHEN if7 => RX_STATUS_TMP <= NOT (RX_STATUS and x"BF00");
						K <= (RX_LEN < MAX_PACKET_LENGTH);				
						N_S <= if8; --s14;
						
			--s14--
			WHEN if8 =>  COUNT_DELAY := COUNT_DELAY + 1;							
						IF COUNT_DELAY >= STD_DELAY THEN
							 I <= I + X"0002";	
							COUNT_DELAY := 0;
							N_S <= if9; --s15;
						ELSE 
							N_S <= if8; --s14;
						END IF;
			--s15--
			WHEN if9 =>  EN <= "10";
						 READENABLE <= '1';
		--				 I <= I + X"0002";									-- need to double check.	 
	
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOR = '1'  and K = TRUE THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= if10; --s16;
	--						GP_o <= '0';
						ELSIF  DONE_IOR = '1'  and K = FALSE THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= if11; --s17;
							GP_o <= '0';
						ELSIF  DONE_IOR = '0' THEN
						    N_S <= if9;
						END IF;
			--s16--			
			WHEN if10 => TMP_OUT <= DOUT;
						 J <= (I < RX_LEN);							  	 
							
						IF (I < RX_LEN) THEN
							N_S <= if8;    --s14;
						ELSE					  
							N_S <= finish;  --s39;
						END IF;
			--s17--
			WHEN if11 =>  TEMP_DATA <= DOUT;   -- Condition for bad packet
						 J <= I < RX_LEN;	 
						
						IF I < RX_LEN THEN
							N_S <= if8;  --s14;
						ELSE						
							N_S <= finish; --s33;
						END IF;
 -- original s18, else part------------------------------------------------------------------------------
			--s18--
			WHEN es0 =>  REG_IOW <= NCR;	--TEMP_REG;				-- need to double check
						 DATA <= X"0003";	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es1;  --s19;
						END IF;
			--s19--
			WHEN es1 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY = TEMP_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= es2;  --s20;
						END IF;
			--s20--
			WHEN es2 =>  REG_IOW <= NCR;	--TEMP_REG;
						 DATA <= X"0000";	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";		 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es3;  --s21;
						END IF;
			--s21--			
			WHEN es3 =>  REG_IOW <= NCR;	--TEMP_REG;  dm9000a_iow (NCR, 03)
						 DATA <= X"0003";	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es4;  --s22;
						END IF;
			--s22--
			WHEN es4 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY >= TEMP_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= es5;  --s23;
						END IF;
			--s23--
			WHEN es5 =>  REG_IOW <= NCR;	--TEMP_REG;
						 DATA <= X"0000";	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es6;  --s24;
						END IF;
			--s24--
			WHEN es6 =>  REG_IOW <= NCR;		--TEMP_REG;
						 DATA <= NCR_Set;	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	  
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es7;  --s25;
						END IF;
			--s25--
			WHEN es7 =>  REG_IOW <= x"08";		--TEMP_REG;
						 DATA <= BPTR_Set; 	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 -- DONE UPTO THIS 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es8; --s26;
						END IF;


--			--s26--
			WHEN es8 =>  REG_IOW <= NCR;		--TEMP_REG;
						 DATA <= x"0003"; 	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 -- DONE UPTO THIS 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es9;  
						END IF;
						
			--s27--
			WHEN es9 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY >= TEMP_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= es10;  
						END IF;
			--s28--				
			WHEN es10 =>  REG_IOW <= NCR;		--TEMP_REG;
						 DATA <= x"0000"; 	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 -- DONE UPTO THIS 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es11;  
						END IF;
			--s29--			
			WHEN es11 =>  REG_IOW <= NCR;		--TEMP_REG;
						 DATA <= x"0003"; 	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 -- DONE UPTO THIS 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es12; 
						END IF;	
			--s30--
		   WHEN es12 =>  COUNT_DELAY := COUNT_DELAY + 1;
							
						IF COUNT_DELAY >= TEMP_DELAY THEN
							COUNT_DELAY := 0;
							N_S <= es13;   
						END IF;		
	    	--s31--			
		  WHEN es13 =>  REG_IOW <= NCR;		--TEMP_REG;
						 DATA <= x"0000"; 	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 -- DONE UPTO THIS 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es14; 
						END IF;				
			
--		  --s32--
			WHEN es14 =>  REG_IOW <= X"09";	--TEMP_REG;
						 DATA <= FCTR_Set;	--TEMP_DATA;
						 EN <= "01";	
						 WRITEENABLE <= "00"; 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es15; --s27;
						END IF;
			--s33--
			WHEN es15 =>  REG_IOW <= X"0A";	--TEMP_REG;
						 DATA <= RTFCR_Set;		--TEMP_DATA;
						 EN <= "01";	 
		     			 WRITEENABLE <= "00";
						
						TEMP_COUNT <= TEMP_COUNT + 1;
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es16;  --s28;
						END IF;
			--s34--
			WHEN es16 =>  REG_IOW <= x"0F";	--TEMP_REG;
						 DATA <= X"0000";	--TEMP_DATA;
						 EN <= "01";	 
		     			 WRITEENABLE <= "00";
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es17;  --s29;
						END IF;
			--s35--
			WHEN es17 =>  REG_IOW <= X"2D";		--TEMP_REG;
						 DATA <= X"0080";	--TEMP_DATA;
						 EN <= "01";	 
		     			 WRITEENABLE <= "00";	 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es18;  --s30;
						END IF;
			--s36--
			WHEN es18 =>  REG_IOW <= ETXCSR;		--TEMP_REG;
						 DATA <= ETXCSR_Set;	--TEMP_DATA;
						 EN <= "01";	 
		     			 WRITEENABLE <= "00";	 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es19; --s31;
						END IF;
			--s37--
			WHEN es19 =>  REG_IOW <= IMR;	--TEMP_REG;				
						 DATA <= INTR_Set;	--TEMP_DATA;
						 EN <= "01";	 
		     			 WRITEENABLE <= "00"; 
						 TEMP_DATA <= X"00" & (RCR_Set  OR	RX_ENABLE	OR	PASS_MULTICAST);	

						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= es20;  --s32;
						END IF;
			--s38--						
			WHEN es20 =>  REG_IOW <= RCR;	--TEMP_REG;
						 DATA <= TEMP_DATA;							-- ????
						 EN <= "01";	 
		     			 WRITEENABLE <= "00"; 
						
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= finish;  --s33;
						END IF;
			--s39--
			WHEN finish =>  GP_o <= '1';
			                RX_LEN <= x"0000";
							I <= x"0000";
						    --N_S <= s0;
							--EN <= "00";
							done_state_machine <= '1';
							N_S <= s40;							EN <= "00";
							
			--s40--
			WHEN s40 => done_state_machine <= '0';
						IF SWDoneRd = '0' THEN
							 REG_IOW <= ISR;	--TEMP_REG;  dm9000a_iow(ISR, 0x3F);l
							 DATA <= X"003F";	--TEMP_DATA;
							 EN <= "01";
							 WRITEENABLE <= "00";	 
						
							TEMP_COUNT <= TEMP_COUNT + 1;	
							IF DONE_IOW = '1' THEN
								TEMP_COUNT <=  (OTHERS => '0');
								INT_umask <= '0';
								N_S <= s41;								
							END IF;							
						END IF;
						
			WHEN s41 =>	 INT_umask <= '1';
						 REG_IOW <= IMR;	--TEMP_REG;  dm9000a_iow(IMR, INTR_set);
						 DATA <= INTR_Set;	--TEMP_DATA;
						 EN <= "01";
						 WRITEENABLE <= "00";	 
					
						TEMP_COUNT <= TEMP_COUNT + 1;	
						IF DONE_IOW = '1' THEN
							TEMP_COUNT <=  (OTHERS => '0');
							N_S <= s0;							EN <= "00";
						END IF;			
						
		END CASE;
	END IF;
END PROCESS;

CLK_COUNTER_R <= TEMP_COUNT;
CLK_COUNTER_W <= TEMP_COUNT;
CLK_OFFSET_R  <= TEMP_COUNT_OFF;
CLK_OFFSET_W  <= TEMP_COUNT_OFF; 
I_DEBUG <= I;

PROCESS(N_S)	   --------------------------- STATE VARIABLE	
		BEGIN
				IF N_S = s00 THEN
					s <= "111111";
				ELSIF N_S = s0 THEN
					s <= "000000";
				ELSIF N_S =s1 THEN
					s <= "000001";
				ELSIF N_S =s2 THEN
					s <= "000010";
				ELSIF N_S =s3 THEN
					s <= "000011";
				ELSIF N_S =s4 THEN
					s <= "000100";
				ELSIF N_S =s5 THEN
					s <= "000101";
				ELSIF N_S =if0 THEN
					s <= "000110";
				ELSIF N_S =if1 THEN
					s <= "000111";
				ELSIF N_S =if2 THEN
					s <= "001000";
				ELSIF N_S =if3 THEN
					s <= "001001";
				ELSIF N_S =if4 THEN
					s <= "001010";
				ELSIF N_S =if5 THEN
					s <= "001011";
				ELSIF N_S =if6 THEN
					s <= "001100";
				ELSIF N_S =if7 THEN
					s <= "001101";
				ELSIF N_S =if8 THEN
					s <= "001110";
				ELSIF N_S =if9 THEN
					s <= "001111";
				ELSIF N_S =if10 THEN
					s <= "010000";
				ELSIF N_S =if11 THEN
					s <= "010001";
				ELSIF N_S =es0 THEN
					s <= "010010";
				ELSIF N_S =es1 THEN
					s <= "010011";
				ELSIF N_S =es2 THEN
					s <= "010100";
				ELSIF N_S =es3 THEN
					s <= "010101";
				ELSIF N_S =es4 THEN
					s <= "010110";
				ELSIF N_S =es5 THEN
					s <= "010111";
				ELSIF N_S =es6 THEN
					s <= "011000";
				ELSIF N_S =es7 THEN
					s <= "011001";
				ELSIF N_S =es8 THEN
					s <= "011010";
				ELSIF N_S =es9 THEN
					s <= "011011";
				ELSIF N_S =es10 THEN
					s <= "011100";
				ELSIF N_S =es11 THEN
					s <= "011101";
				ELSIF N_S =es12 THEN
					s <= "011110";
				ELSIF N_S =es13 THEN
					s <= "011111";
				ELSIF N_S =es14 THEN
					s <= "100000";
				ELSIF N_S =es15 THEN
					s <= "100001";				
				ELSIF N_S =es16 THEN
					s <= "100010";
				ELSIF N_S =es17 THEN
					s <= "100011";
				ELSIF N_S =es18 THEN
					s <= "100100";
				ELSIF N_S =es19 THEN
					s <= "100101";
				ELSIF N_S =es20 THEN
					s <= "100110";		
				ELSIF N_S = finish THEN
					s <= "100111";
				ELSIF N_S = s40 THEN
					s <= "101000";
				ELSIF N_S = s41 THEN
					s <= "101001";
				ELSE s <="111000";
		END IF;
	  END PROCESS;
END BEHAVIOR;
