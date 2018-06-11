library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ha_dm9000aCustom is 
	port(
		clk        : in  std_logic;
    reset_n    : in  std_logic;
    read_n       : in  std_logic;
    write_n      : in  std_logic;
    chipselect : in  std_logic;
    address    : in  std_logic_vector(4 downto 0);
    readdata   : out std_logic_vector(15 downto 0);
    writedata  : in  std_logic_vector(15 downto 0);

		-- Export
    -- DMA9000 PHY Connections
	ENET_DATA : inout std_logic_vector(15 downto 0);    -- DATA bus 16Bits
    ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
    ENET_CS_N,                                          -- Chip Select
    ENET_WR_N,                                          -- Write
    ENET_RD_N,                                          -- Read
    ENET_RST_N,                                         -- Reset
    ENET_CLK : out std_logic;                           -- Clock 25 MHz
    ENET_INT : in std_logic;                            -- Interrupt
	LEDR : out std_logic_vector(17 downto 0);      -- Red LEDs
	SW   : in std_logic_vector(17 downto 0);         -- DPDT switches
	KEY  : in std_logic_vector(3 downto 0);         -- Push buttons

	-- CPU Connections
	interrupt1: out std_logic
		
		
	);
end ha_dm9000aCustom;

architecture behavior of ha_dm9000aCustom is
	type ram_type is array(15 downto 0) of unsigned(15 downto 0);
  signal RAM : ram_type;
  signal ram_address : unsigned(3 downto 0);
	signal temp_interrupt : std_logic_vector(0 downto 0);
	signal temp_initFlag : std_logic_vector(0 downto 0);

  signal price    : unsigned(31 downto 0);
	signal name     : unsigned(31 downto 0);
	signal buysell  : unsigned(7 downto 0);
	signal quantity : unsigned(31 downto 0);

	signal intRcv   : std_logic;
	signal intClear : std_logic;

  signal initFlag : std_logic;
	signal tempdata : std_logic_vector(15 downto 0);
	signal clk25 : std_logic := '0';
	signal counter : unsigned(15 downto 0);
	signal reset_n2 : std_logic;

begin
	--ram_address <= address(3 downto 0);
	LEDR(11) <= '1';
	--ENET_DATA <= tempdata when write_n='0' else (others => 'Z');
	
	
	
process (clk)
  begin
    if rising_edge(clk) then
      clk25 <= not clk25;
	  if counter = x"ffff" then
        reset_n2 <= '1';
      else
        reset_n2 <= '0';
        counter <= counter + 1;
      end if;
    end if;
	
end process;

ENET_CLK <= clk25;

	ENET_DATA <= writedata when write_n='0' else (others => 'Z');
	readdata	<=	ENET_DATA;
	interrupt1  <=	ENET_INT;
	--tempdata 	<=	writedata;
	ENET_CMD 	<=	address(0);
	ENET_CS_N 	<=	chipselect;
	ENET_RD_N 	<=	read_n;
	ENET_WR_N 	<=	write_n;
	ENET_RST_N  <= reset_n;






--  process (clk)
--  begin
--    if rising_edge(clk) then
--		if reset_n = '0' then
--			tempdata 	<=	(others => '0');
--			ENET_CMD 	<=	'0';
--			ENET_RD_N 	<=	'1';
--			ENET_WR_N 	<=	'1';
--			ENET_CS_N 	<=	'1';
--			readdata	<=	(others => '0');
--			interrupt1			<=	'0';
--			ENET_RST_N  <= reset_n;
--		else
--		ENET_DATA <= writedata when write_n='0' else (others => 'Z');
--			readdata	<=	ENET_DATA;
--			interrupt1  <=	ENET_INT;
--			--tempdata 	<=	writedata;
--			ENET_CMD 	<=	address(0);
--			ENET_CS_N 	<=	chipselect;
--			ENET_RD_N 	<=	read_n;
--			ENET_WR_N 	<=	write_n;
--			ENET_RST_N  <= reset_n;
--		end if;
--	end if;
----      if reset_n = '0' then
----        readdata <= (others => '0');
----      else
----        if chipselect = '1' then
----          if read = '1' then
----            readdata <= RAM(to_integer(ram_address))(15 downto 0);
----          elsif write = '1' then
----            RAM(to_integer(ram_address)) <= writedata;
----          end if;
----        else
--
--		
--
--
--
----			RAM(to_integer("0001")) (15 downto 0) <= x"0064"; --100 --price;
----			RAM(to_integer("0010")) (15 downto 0) <= x"0074";
----			
----			RAM(to_integer("0011")) (15 downto 0) <= x"494D"; --(MICR) --name;
----			RAM(to_integer("0100")) (15 downto 0) <= x"5243"; -- CR
----			
----			RAM(to_integer("0101")) (15 downto 0) <=  x"0031"; --(Buy -1)--buysell;
----			
----			RAM(to_integer("0110")) (15 downto 0) <= x"0050"; --10 --quantity;
----			RAM(to_integer("0111")) (15 downto 0) <= x"0051";
----
----			temp_initFlag <= std_logic_vector(RAM(to_integer("0000")) (0 downto 0)) ;
----			--initFlag <= temp_initFlag(0);
----			
----			if RAM(to_integer("0000")) (0) = '0' then  -- software is done working on interrupt
----				--if intRcv = '1' then
----					RAM(to_integer("0000")) (0) <= intRcv;  --"1";  -- intRcv
--					
--					--interrupt <= '1';
--				--else
--				--end if;
--			--else
--					--intClear <= RAM(to_integer("0101")) (0); --software sets clear addr to indicate interrupt handle is done
--			--end if;
----			temp_interrupt <= std_logic_vector(RAM(to_integer("0000")) (0 downto 0));
----			interrupt1 <= temp_interrupt(0);
----			initFlag <= temp_interrupt(0);  -- just for testing the interrupt
--					
----        end if;
----      end if;
-- 
--  end process;
end behavior;
