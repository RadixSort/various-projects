--
-- DE2 top-level module that includes the simple VGA raster generator
--
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--
-- From an original by Terasic Technology, Inc.
-- (DE2_TOP.v, part of the DE2 system board CD supplied by Altera)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity proj1 is

  port (
    -- Clocks
    
    CLOCK_27,                                      -- 27 MHz
    CLOCK_50,                                      -- 50 MHz
    EXT_CLOCK : in std_logic;                      -- External Clock

    -- Buttons and switches
    
    KEY : in std_logic_vector(3 downto 0);         -- Push buttons
    SW : in std_logic_vector(17 downto 0);         -- DPDT switches

    -- LED displays

    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 -- 7-segment displays
       : out std_logic_vector(6 downto 0);
    LEDG : out std_logic_vector(8 downto 0);       -- Green LEDs
    LEDR : out std_logic_vector(17 downto 0);      -- Red LEDs

    -- RS-232 interface

    UART_TXD : out std_logic;                      -- UART transmitter   
    UART_RXD : in std_logic;                       -- UART receiver

    -- IRDA interface

--    IRDA_TXD : out std_logic;                      -- IRDA Transmitter
    IRDA_RXD : in std_logic;                       -- IRDA Receiver

    -- SDRAM
   
    DRAM_DQ : inout std_logic_vector(15 downto 0); -- Data Bus
    DRAM_ADDR : out std_logic_vector(11 downto 0); -- Address Bus    
    DRAM_LDQM,                                     -- Low-byte Data Mask 
    DRAM_UDQM,                                     -- High-byte Data Mask
    DRAM_WE_N,                                     -- Write Enable
    DRAM_CAS_N,                                    -- Column Address Strobe
    DRAM_RAS_N,                                    -- Row Address Strobe
    DRAM_CS_N,                                     -- Chip Select
    DRAM_BA_0,                                     -- Bank Address 0
    DRAM_BA_1,                                     -- Bank Address 0
    DRAM_CLK,                                      -- Clock
    DRAM_CKE : out std_logic;                      -- Clock Enable

    -- FLASH
    
    FL_DQ : inout std_logic_vector(7 downto 0);      -- Data bus
    FL_ADDR : out std_logic_vector(21 downto 0);  -- Address bus
    FL_WE_N,                                         -- Write Enable
    FL_RST_N,                                        -- Reset
    FL_OE_N,                                         -- Output Enable
    FL_CE_N : out std_logic;                         -- Chip Enable

    -- SRAM
    
    SRAM_DQ : inout std_logic_vector(15 downto 0); -- Data bus 16 Bits
    SRAM_ADDR : out std_logic_vector(17 downto 0); -- Address bus 18 Bits
    SRAM_UB_N,                                     -- High-byte Data Mask 
    SRAM_LB_N,                                     -- Low-byte Data Mask 
    SRAM_WE_N,                                     -- Write Enable
    SRAM_CE_N,                                     -- Chip Enable
    SRAM_OE_N : out std_logic;                     -- Output Enable

    -- USB controller
    
    OTG_DATA : inout std_logic_vector(15 downto 0); -- Data bus
    OTG_ADDR : out std_logic_vector(1 downto 0);    -- Address
    OTG_CS_N,                                       -- Chip Select
    OTG_RD_N,                                       -- Write
    OTG_WR_N,                                       -- Read
    OTG_RST_N,                                      -- Reset
    OTG_FSPEED,                     -- USB Full Speed, 0 = Enable, Z = Disable
    OTG_LSPEED : out std_logic;     -- USB Low Speed, 0 = Enable, Z = Disable
    OTG_INT0,                                       -- Interrupt 0
    OTG_INT1,                                       -- Interrupt 1
    OTG_DREQ0,                                      -- DMA Request 0
    OTG_DREQ1 : in std_logic;                       -- DMA Request 1   
    OTG_DACK0_N,                                    -- DMA Acknowledge 0
    OTG_DACK1_N : out std_logic;                    -- DMA Acknowledge 1

    -- 16 X 2 LCD Module
    
    LCD_ON,                     -- Power ON/OFF
    LCD_BLON,                   -- Back Light ON/OFF
    LCD_RW,                     -- Read/Write Select, 0 = Write, 1 = Read
    LCD_EN,                     -- Enable
    LCD_RS : out std_logic;     -- Command/Data Select, 0 = Command, 1 = Data
    LCD_DATA : inout std_logic_vector(7 downto 0); -- Data bus 8 bits

    -- SD card interface
    
    SD_DAT,                     -- SD Card Data
    SD_DAT3,                    -- SD Card Data 3
    SD_CMD : inout std_logic;   -- SD Card Command Signal
    SD_CLK : out std_logic;     -- SD Card Clock

    -- USB JTAG link
    
    TDI,                        -- CPLD -> FPGA (data in)
    TCK,                        -- CPLD -> FPGA (clk)
    TCS : in std_logic;         -- CPLD -> FPGA (CS)
    TDO : out std_logic;        -- FPGA -> CPLD (data out)

    -- I2C bus
    
    I2C_SDAT : inout std_logic; -- I2C Data
    I2C_SCLK : out std_logic;   -- I2C Clock

    -- PS/2 port

    PS2_DAT,                    -- Data
    PS2_CLK : in std_logic;     -- Clock

    -- VGA output
    
    VGA_CLK,                                            -- Clock
    VGA_HS,                                             -- H_SYNC
    VGA_VS,                                             -- V_SYNC
    VGA_BLANK,                                          -- BLANK
    VGA_SYNC : out std_logic;                           -- SYNC
    VGA_R,                                              -- Red[9:0]
    VGA_G,                                              -- Green[9:0]
    VGA_B : out unsigned(9 downto 0);                   -- Blue[9:0]

    --  Ethernet Interface
    
    ENET_DATA : inout std_logic_vector(15 downto 0);    -- DATA bus 16Bits
    ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
    ENET_CS_N,                                          -- Chip Select
    ENET_WR_N,                                          -- Write
    ENET_RD_N,                                          -- Read
    ENET_RST_N,                                         -- Reset
    ENET_CLK : out std_logic;                           -- Clock 25 MHz
    ENET_INT : in std_logic;                            -- Interrupt
    
    -- Audio CODEC
    
    AUD_ADCLRCK : inout std_logic;                      -- ADC LR Clock
    AUD_ADCDAT : in std_logic;                          -- ADC Data
    AUD_DACLRCK : inout std_logic;                      -- DAC LR Clock
    AUD_DACDAT : out std_logic;                         -- DAC Data
    AUD_BCLK : inout std_logic;                         -- Bit-Stream Clock
    AUD_XCK : out std_logic;                            -- Chip Clock
    
    -- Video Decoder
    
    TD_DATA : in std_logic_vector(7 downto 0);  -- Data bus 8 bits
    TD_HS,                                      -- H_SYNC
    TD_VS : in std_logic;                       -- V_SYNC
    TD_RESET : out std_logic;                   -- Reset
    
    -- General-purpose I/O
    
    GPIO_0,                                      -- GPIO Connection 0
    GPIO_1 : inout std_logic_vector(35 downto 0) -- GPIO Connection 1   
    );
  
end proj1;

architecture datapath of proj1 is

  signal clk25 : std_logic := '0';
  signal reset_n : std_logic;
  signal counter : unsigned(15 downto 0);
    signal mux_NIOS_ENET_DATA : std_logic_vector(15 downto 0);    -- DATA bus 16Bits
    signal mux_NIOS_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
    mux_NIOS_ENET_CS_N,                                          -- Chip Select
    mux_NIOS_ENET_WR_N,                                          -- Write
    mux_NIOS_ENET_RD_N,                                          -- Read
    mux_NIOS_ENET_RST_N : std_logic;                                         -- Reset



    signal mux_RECV_ENET_DATA : std_logic_vector(15 downto 0);    -- DATA bus 16Bits
    signal mux_RECV_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
    mux_RECV_ENET_CS_N,                                          -- Chip Select
    mux_RECV_ENET_WR_N,                                          -- Write
    mux_RECV_ENET_RD_N: std_logic;                                          -- Read
    signal mux_RECV_ENET_RST_N: std_logic;                           -- 

signal clk_count : std_logic_vector(10 downto 0) := (others => '0');
signal enableWrite: std_logic;
signal enableRead: std_logic;
signal muxSwitch:std_logic:='0';



begin

  process (CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then
      clk25 <= not clk25;
  if counter = x"ffff" then
        reset_n <= '1';
      else
        reset_n <= '0';
        counter <= counter + 1;
      end if;
    end if;
  end process;

 

  LEDR(17) <= '1';
  LEDR(16) <= '0';

nios : entity work.nios_system port map (
    clk                          => CLOCK_50,
    reset_n                      => reset_n,
--    leds_from_the_leds           => LEDR(15 downto 0),
--centreH_from_the_vga		 => centreH,
--centreV_from_the_vga		 => centreV,
    SRAM_ADDR_from_the_sram      => SRAM_ADDR,
    SRAM_CE_N_from_the_sram      => SRAM_CE_N,
    SRAM_DQ_to_and_from_the_sram => SRAM_DQ,
    SRAM_LB_N_from_the_sram      => SRAM_LB_N,
    SRAM_OE_N_from_the_sram      => SRAM_OE_N,
    SRAM_UB_N_from_the_sram      => SRAM_UB_N,
    SRAM_WE_N_from_the_sram      => SRAM_WE_N,

		ENET_CMD_from_the_dm9000aCustom 	=>ENET_CMD,
		ENET_CS_N_from_the_dm9000aCustom =>ENET_CS_N,
		ENET_DATA_to_and_from_the_dm9000aCustom  =>ENET_DATA,
		ENET_INT_to_the_dm9000aCustom  => ENET_INT,
		ENET_RD_N_from_the_dm9000aCustom  => ENET_RD_N,
		ENET_RST_N_from_the_dm9000aCustom=> ENET_RST_N,
		ENET_WR_N_from_the_dm9000aCustom  => ENET_WR_N,
		enableSignal_to_the_dm9000aCustom => SW(15 downto 0)
		
--		ENET_CMD_from_the_dm9000aCustom 	=>mux_NIOS_ENET_CMD,
--		ENET_CS_N_from_the_dm9000aCustom =>mux_NIOS_ENET_CS_N,
--		ENET_DATA_to_and_from_the_dm9000aCustom  =>ENET_DATA,
--		ENET_INT_to_the_dm9000aCustom  => ENET_INT,
--		ENET_RD_N_from_the_dm9000aCustom  => mux_NIOS_ENET_RD_N,
--		ENET_RST_N_from_the_dm9000aCustom=> mux_NIOS_ENET_RST_N,
--		ENET_WR_N_from_the_dm9000aCustom  => mux_NIOS_ENET_WR_N,
--		enableSignal_to_the_dm9000aCustom => SW(4)

    );
  

--mux : entity work.multiplexer port map (
--		s=>muxSwitch,
--		clk=>CLOCK_50,
--   -- mux_NIOS_ENET_DATA => mux_NIOS_ENET_DATA,    -- DATA bus 16Bits
--    mux_NIOS_ENET_CMD => mux_NIOS_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
--    mux_NIOS_ENET_CS_N => mux_NIOS_ENET_CS_N,                                          -- Chip Select
--    mux_NIOS_ENET_WR_N => mux_NIOS_ENET_WR_N,                                          -- Write
--    mux_NIOS_ENET_RD_N => mux_NIOS_ENET_RD_N,                                          -- Read
--    mux_NIOS_ENET_RST_N => mux_NIOS_ENET_RST_N,                                         -- Reset
--                               -- Interrupt
--
--    --mux_RECV_ENET_DATA => mux_RECV_ENET_DATA,    -- DATA bus 16Bits
--    mux_RECV_ENET_CMD=>mux_RECV_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
--    mux_RECV_ENET_CS_N=>mux_RECV_ENET_CS_N,                                          -- Chip Select
--    mux_RECV_ENET_WR_N=>mux_RECV_ENET_WR_N,                                          -- Write
--    mux_RECV_ENET_RD_N=>mux_RECV_ENET_RD_N,                                          -- Read
--    mux_RECV_ENET_RST_N=>mux_RECV_ENET_RST_N,                                         -- Reset
--
--    --out_ENET_DATA =>ENET_DATA,    -- DATA bus 16Bits
--    out_ENET_CMD=>ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
--    out_ENET_CS_N=>ENET_CS_N,                                          -- Chip Select
--    out_ENET_WR_N=>ENET_WR_N,                                          -- Write
--    out_ENET_RD_N=>ENET_RD_N,                                          -- Read
--    out_ENET_RST_N=>ENET_RST_N,                                         -- Reset
--    out_ENET_INT=>ENET_INT                            -- Interrupt
--
--				);


--recieve : entity work.recieve_packet port map (
--
--    ENET_DATA =>mux_RECV_ENET_DATA,    -- DATA bus 16Bits
--    ENET_CMD=>mux_RECV_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
--    ENET_CS_N=>mux_RECV_ENET_CS_N,                                          -- Chip Select
--    ENET_WR_N=>mux_RECV_ENET_WR_N,                                          -- Write
--    ENET_RD_N=>mux_RECV_ENET_RD_N,                                          -- Read
--    ENET_RST_N=>mux_RECV_ENET_RST_N,                                         -- Reset
--    ENET_INT =>ENET_INT,                           -- Interrupt
--		clk=>clk25
--
--);

process (CLOCK_50)
  begin -- process DO_CLKDIV
		--if(CLOCK_50'event) then
			--enableWrite<=SW(2);
			enableRead<=SW(2);
			muxSwitch<=SW(0);
			if SW(1) = '0' then -- asynchronous reset (active low)
				clk_count <= (others => '0');
      else
        clk_count <= clk_count + 1;
      end if;

		--end if;
 end process ;









--write_data_reg : entity work. io_write_data port map(
--			reg =>X"10",
--			data =>X"FF0F",
--			clk_offset=>X"00",
--			clk_cnt=> clk_count,
--			clk =>clk25,
--
--			EN =>enableWrite,
--			--interrupt : in std_logic;
--			--reset : out std_logic;
--			--reset_clk_cnt
--			DM_IOW_n =>mux_RECV_ENET_WR_N,
--			DM_CMD =>mux_RECV_ENET_CMD,
--			DONE=>LEDR(15),
--			DM_SD =>mux_RECV_ENET_DATA
--			--s 
--	 );

--read_data_reg : entity work. io_read_data port map(
--			reg =>X"01",
--			clk_offset=>(others => '0'),
--			clk_cnt =>clk_count,
--			clk =>CLOCK_50,
--
--			EN =>enableRead,
--			interrupt : in std_logic;
--			reset : out std_logic;
--			DM_IOW_n =>mux_RECV_ENET_WR_N,
--			DM_IOR_n =>mux_RECV_ENET_RD_N,
--			DM_CMD => mux_RECV_ENET_CMD,
--			DM_SD => ENET_DATA,
--			DM_CS=>mux_RECV_ENET_CS_N,
--			DM_RST_N=>mux_RECV_ENET_RST_N
--	 );




  HEX7     <= "0001001"; -- Leftmost
  HEX6     <= "0000110";
  HEX5     <= "1000111";
  HEX4     <= "1000111";
  HEX3     <= "1000000";
  HEX2     <= (others => '1');
  HEX1     <= (others => '1');
  HEX0     <= (others => '1');          -- Rightmost
  LEDG     <= (others => '1');
 -- LEDR     <= (others => '1');
  LCD_ON   <= '1';
  LCD_BLON <= '1';
  LCD_RW <= '1';
  LCD_EN <= '0';
  LCD_RS <= '0';

  SD_DAT3 <= '1';  
  SD_CMD <= '1';
  SD_CLK <= '1';

  SRAM_DQ <= (others => 'Z');
 -- SRAM_ADDR <= (others => '0');
  --SRAM_UB_N <= '1';
  --SRAM_LB_N <= '1';
 -- SRAM_CE_N <= '1';
 -- SRAM_WE_N <= '1';
 -- SRAM_OE_N <= '1';

  UART_TXD <= '0';
  DRAM_ADDR <= (others => '0');
  DRAM_LDQM <= '0';
  DRAM_UDQM <= '0';
  DRAM_WE_N <= '1';
  DRAM_CAS_N <= '1';
  DRAM_RAS_N <= '1';
  DRAM_CS_N <= '1';
  DRAM_BA_0 <= '0';
  DRAM_BA_1 <= '0';
  DRAM_CLK <= '0';
  DRAM_CKE <= '0';
  FL_ADDR <= (others => '0');
  FL_WE_N <= '1';
  FL_RST_N <= '0';
  FL_OE_N <= '1';
  FL_CE_N <= '1';
  OTG_ADDR <= (others => '0');
  OTG_CS_N <= '1';
  OTG_RD_N <= '1';
  OTG_RD_N <= '1';
  OTG_WR_N <= '1';
  OTG_RST_N <= '1';
  OTG_FSPEED <= '1';
  OTG_LSPEED <= '1';
  OTG_DACK0_N <= '1';
  OTG_DACK1_N <= '1';

  TDO <= '0';

--  ENET_CMD <= '0';
--  ENET_CS_N <= '1';
--  ENET_WR_N <= '1';
--  ENET_RD_N <= '1';
--	ENET_RST_N <= reset_n;
	ENET_CLK <= clk25;
  
  TD_RESET <= '0';
  
  I2C_SCLK <= '1';

  AUD_DACDAT <= '1';
  AUD_XCK <= '1';
  
  -- Set all bidirectional ports to tri-state
  DRAM_DQ     <= (others => 'Z');
  FL_DQ       <= (others => 'Z');
  SRAM_DQ     <= (others => 'Z');
  OTG_DATA    <= (others => 'Z');
  LCD_DATA    <= (others => 'Z');
  SD_DAT      <= 'Z';
  I2C_SDAT    <= 'Z';
  --ENET_DATA   <= (others => '0');
  AUD_ADCLRCK <= 'Z';
  AUD_DACLRCK <= 'Z';
  AUD_BCLK    <= 'Z';
  GPIO_0      <= (others => 'Z');
  GPIO_1      <= (others => 'Z');

end datapath;
--
-- DE2 top-level module that includes the simple VGA raster generator
--
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--
-- From an original by Terasic Technology, Inc.
-- (DE2_TOP.v, part of the DE2 system board CD supplied by Altera)
--
