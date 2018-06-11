library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity io_read_data is
	port(
			reg : in std_logic_vector(7 downto 0); -- register address
			dout : out std_logic_vector(15 downto 0);
			clk_offset : in std_logic_vector(10 downto 0); -- clock offset
			clk_cnt : in std_logic_vector(10 downto 0);
			clk : in std_logic;
			readonly: in std_logic; -- if readonly=0, module performs all the opeartion from STEP0 to STEP9 and works similar to dm9000a_ior function from DM9000A.c
															-- if readonly=1 module mimicks to operation of IORD function from DM9000A.h
			EN : in std_logic;			-- signal from controller to wake this hardware module
			DM_IOW_n : out std_logic;	-- write_enable(active low) signal to ENET_WR_N
			DM_IOR_n : out std_logic;-- read_enable(active low) signal to ENET_RD_N
			DM_CMD : out std_logic;	-- command signal ENET_CMD Index/Data Select, 0=Index , 1 = Data
			DONE: out std_logic;		-- sends an indication to module calling io_read_data module when the read operation is completed.
			iData2 : inout std_logic_vector(15 downto 0); -- iData2 is being fed to ENET_Data via tristate buffer
			DM_CS: out std_logic;				-- Chipselect to ENET_CS_N (active low)
			DM_RST_N: out std_logic;		-- DM_RST to ENET_RST_N reset_n
			s : buffer std_logic_vector(3 downto 0) -- for debugging purposes only
	 );
end io_read_data;

architecture rtl_comb of io_read_data is

type states is (STEP0,STEP1, STEP2, STEP3,STEP4,STEP5,STEP6,STEP7,STEP8,STEP9);
signal y: states;

--signal STDdelay: std_logic_vector(10 downto 0):="00000001010"; -- binary of 10
signal STDdelay: std_logic_vector(10 downto 0):="00001100100"; -- binary of 100
--signal STDdelay: std_logic_vector(10 downto 0):="01111101000"; -- binary of 1000																										

begin -- begining of architecture

process(clk_cnt, EN)
begin
if (EN = '0') then
	y <= STEP0;
	DM_CS<='1';
	DM_RST_N<='1';
	DM_IOW_n <= '1';
	DM_IOR_n <= '1';
	DM_CMD   <= '0';
elsif (clk'EVENT and clk = '1') then
case y is 
	when STEP0=>if (EN = '1') then 
									DM_RST_N<='1';
									DONE <= '0';
									if(readonly='1') then
											STDdelay<=(others=>'0');
											y <= STEP5;
									else
											--STDdelay<="00000001010";--10
											STDdelay<="00001100100";--100
											--STDdelay<="01111101000";--1000
											y <= STEP1;
									end if;
									
							else
									y<=STEP0;
							end if;
							
	when STEP1=>if clk_cnt = clk_offset then
									DM_CS<='0';
									DM_CMD   <= '0';-- -- Index/Data Select, 0=Index , 1 = Data
									DM_IOW_n <= '1';
									DM_IOR_n <= '1';
									y<=STEP2;
							else
									y<=STEP1;
							end if;
	-- STEP2 bring WR signal to active low and start writing data on the databus 	
	when STEP2=>if clk_cnt = clk_offset + 1 then -- 
									DM_CS<='0';
									DM_IOW_n <= '0';
									iData2   <= X"00" & reg;	
									y<=STEP3;
							else
									y<=STEP2;
							end if;
	-- STEP3 bring WR signal to active high
	when STEP3=>if clk_cnt = clk_offset + 2 then
	-- adding delay
								DM_CS<='0';
								DM_IOW_n <= '1';
								y<=STEP4;
							else
								y<=STEP3;
							end if;
	-- STEP4 make CMD signal high and Chipselect to active low and enable(DM_tri) tristate buffer on databus to HIGH Z  
	when STEP4=>if clk_cnt= clk_offset + 3 then -- 
								DM_CS<='1';
								DM_CMD   <= '1';
								DM_IOR_n <= '1';	
								y<=STEP5;
							else
								y<=STEP4;
							end if;
	-- STEP5 wait for 1us = 
	when STEP5=>if clk_cnt = clk_offset + STDdelay then
								DM_CMD   <= '1';
								DM_CS<='0';
								DM_IOR_n <= '1';
								y<=STEP6;
							else
								y<=STEP5;
							end if;
	when STEP6=>if clk_cnt = clk_offset + STDdelay+ 1 then
								DM_IOR_n <= '0';
								DM_CMD   <= '1';
								y<=STEP7;
							else
								y<=STEP6;
							end if;
							
	when STEP7=>if clk_cnt = clk_offset + STDdelay+2 then
								DM_CS<='0';
								DM_IOR_n <= '1';
								y<=STEP8;
							else
								y<=STEP7;
							end if;
							
	when STEP8=>if clk_cnt = clk_offset + STDdelay+4 then
								DM_CS<='1';
								DM_CMD   <= '0';
								DM_IOR_n <= '1';
								DONE<='1';
								y<=STEP9;
							else
								y<=STEP8;
							end if;
							
	when STEP9=>if(clk_cnt=clk_offset + STDdelay + 5) then
								DONE<='0';
								y<=STEP0;
						else
								y<=STEP9;
						end if;
	end case;
	end if;
end process;



PROCESS(y)	   --------------------------- STATE VARIABLE	
BEGIN
	IF y =STEP0 THEN
		s <= "0000";
	ELSIF y =STEP1 THEN
		s <= "0001";
	ELSIF y =STEP2 THEN
		s <= "0010";
	ELSIF y =STEP3 THEN
		s <= "0011";
	ELSIF y =STEP4 THEN
		s <= "0100";
	ELSIF y =STEP5 THEN
		s <= "0101";
	ELSIF y =STEP6 THEN
		s <= "0110";
	ELSIF y =STEP7 THEN
		s <= "0111";
	ELSIF y =STEP8 THEN
		s <= "1000";
	ELSIF y =STEP9 THEN
		s <= "1001";
	end if;
end process;
end rtl_comb;
