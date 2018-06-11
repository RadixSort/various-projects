library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dm9000a is 
  port(
		signal iRD_N,iWR_N,iCS_N,iRST_N: in std_logic;
		signal address    : in  unsigned(9 downto 0);
        signal iDATA: in std_logic_vector(15 downto 0);
		signal oDATA: out std_logic_vector(15 downto 0);
		signal oINT: out std_logic;
		--  DM9000A Side
        signal ENET_DATA: inout std_logic_vector(15 downto 0);
		signal ENET_CMD,
               ENET_RD_N,ENET_WR_N,
               ENET_CS_N,ENET_RST_N: out std_logic;
        signal ENET_INT: in std_logic;
		signal clockInput: in std_logic;
		signal enableSignal: in std_logic_vector(15 downto 0)
       );
end dm9000a;
architecture behavior of dm9000a is

component io_read_data is
	port(
			reg : in std_logic_vector(7 downto 0);
			dout : out std_logic_vector(15 downto 0);
			clk_offset : in std_logic_vector(10 downto 0);
			clk_cnt : in std_logic_vector(10 downto 0);
			clk : in std_logic;
			readonly: in std_logic;

			EN : in std_logic;
			DM_IOW_n : out std_logic;
			DM_IOR_n : out std_logic;
			DM_CMD : out std_logic;
			DONE: out std_logic;
			iDATA2 : inout std_logic_vector(15 downto 0);
			DM_CS: out std_logic;
			DM_RST_N: out std_logic;
			s : buffer std_logic_vector(3 downto 0)
	 );
end component;


component io_write_data is
	port(
			reg : in std_logic_vector(7 downto 0);
			data : in std_logic_vector(15 downto 0);
			clk_offset : in std_logic_vector(10 downto 0);
			clk_cnt : in std_logic_vector(10 downto 0);
			clk : in std_logic;
			writeOnly: in std_logic_vector(1 downto 0); -- if writeOnly = "00" or "11" normal operation write data to Register reg
																						-- if writeOnly = "01" write data to location addressed by a previous statement
																						-- if writeOnly ="10" write a register address to databus
			EN : in std_logic;
			--interrupt : in std_logic;
			--reset : out std_logic;
			DM_IOW_n : out std_logic;
			DM_IOR_n : out std_logic;
			DM_CMD : out std_logic;
			DONE: out std_logic;
			iDATA2 : inout std_logic_vector(15 downto 0);
			DM_CS: out std_logic;
			DM_RST_N: out std_logic;
			s : buffer std_logic_vector(3 downto 0)
	 );
end component;

component multiplexer is
	port(
				s : in std_logic;
				signal mux_IO_read_data_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
				mux_IO_read_data_ENET_CS_N,                                          -- Chip Select
				mux_IO_read_data_ENET_WR_N,                                          -- Write
				mux_IO_read_data_ENET_RD_N,                                          -- Read
				mux_IO_read_data_ENET_RST_N : std_logic;                                         -- Reset
				signal iData2read: std_logic_vector(15 downto 0);

				signal mux_IO_write_data_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
				mux_IO_write_data_ENET_CS_N,                                          -- Chip Select
				mux_IO_write_data_ENET_WR_N,                                          -- Write
				mux_IO_write_data_ENET_RD_N,                                         -- Read
				mux_IO_write_data_ENET_RST_N: std_logic;                           -- 
				signal iData2write:std_logic_vector(15 downto 0);
								
				out_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
				out_ENET_CS_N,                                          -- Chip Select
				out_ENET_WR_N,                                          -- Write
				out_ENET_RD_N,                                          -- Read
				out_ENET_RST_N : out std_logic;                         -- Reset
				iData2: out std_logic_vector(15 downto 0)
				);
end component;





component dm9000_hw IS
PORT(

	-- inputs
	CLK,
	DONE_IOR,
	DONE_IOW,
	INIT_DONE,
	ENT_IN				: IN STD_LOGIC;
	DOUT				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	RX_length			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	RX_statusIn 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	SWDoneRd 			: IN STD_LOGIC;	

	-- outputs	
	REG_IOR				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	REG_IOW				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	DATA				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	 
	READENABLE			: OUT STD_LOGIC;							-- added for new design
	WRITEENABLE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	
	EN					: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); 		-- modified for new design
	TMP_OUT				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	DONE_Reading_Packet : OUT STD_LOGIC;
	
	I_DEBUG				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	INT_umask           : OUT STD_LOGIC;
	GP_o				: OUT STD_LOGIC;	
	CLK_OFFSET_R		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
	CLK_OFFSET_W		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
	CLK_COUNTER_R		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);	
	CLK_COUNTER_W		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);	

	-- not required for design but useful to debug
	s: BUFFER STD_LOGIC_VECTOR(5 downto 0)						

);
END component;





component debug_intermediate_signals_modules is
port(

	RXbuffer0: in std_logic_vector(15 downto 0);
	RXbuffer1: in std_logic_vector(15 downto 0);
	RXbuffer2: in std_logic_vector(15 downto 0);
	RXbuffer3: in std_logic_vector(15 downto 0);
	RXbuffer4: in std_logic_vector(15 downto 0);
	RXbuffer5: in std_logic_vector(15 downto 0);
	RXbuffer6: in std_logic_vector(15 downto 0);
--	RXbuffer01: in std_logic_vector(15 downto 0);
--	RXbuffer11: in std_logic_vector(15 downto 0);
--	RXbuffer21: in std_logic_vector(15 downto 0);
--	RXbuffer31: in std_logic_vector(15 downto 0);
--	RXbuffer41: in std_logic_vector(15 downto 0);
--	RXbuffer51: in std_logic_vector(15 downto 0);
--	RXbuffer61: in std_logic_vector(15 downto 0);
	messageCounter:in integer;
	stateCounter: in std_logic_vector(5 downto 0);
	timeHwRead:out std_logic_vector(31 downto 0);
	timeSwHwRead:out std_logic_vector(31 downto 0);
	clk: in std_logic
 );
end component;

-- signal from io_read_data module to multiplexor 
signal mux_IO_read_data_ENET_DATA : std_logic_vector(15 downto 0);    -- DATA bus 16Bits
signal mux_IO_read_data_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
mux_IO_read_data_ENET_CS_N,                                          -- Chip Select
mux_IO_read_data_ENET_WR_N,                                          -- Write
mux_IO_read_data_ENET_RD_N,                                          -- Read
mux_IO_read_data_ENET_RST_N : std_logic;                                         -- Reset

-- signal from io_write_data module to multiplexor 
signal mux_IO_write_data_ENET_DATA : std_logic_vector(15 downto 0);    -- DATA bus 16Bits
signal mux_IO_write_data_ENET_CMD,           -- Command/Data Select, 0 = Command, 1 = Data
mux_IO_write_data_ENET_CS_N,                                          -- Chip Select
mux_IO_write_data_ENET_WR_N,                                          -- Write
mux_IO_write_data_ENET_RD_N: std_logic;                                          -- Read
signal mux_IO_write_data_ENET_RST_N: std_logic;                           -- 

signal clk_count: std_logic_vector(10 downto 0) ;
signal DONE: std_logic;
signal iDATA2: std_logic_vector(15 downto 0);
signal iDATA2read: std_logic_vector(15 downto 0);
signal iDATA2write: std_logic_vector(15 downto 0);
signal oDATA2: std_logic_vector(15 downto 0);
signal oDATA2read: std_logic_vector(15 downto 0);
signal oDATA2write: std_logic_vector(15 downto 0);


signal sel:std_logic:='0';
signal muxSwitch_read_write:std_logic:='0';

-- output signals for multiplexor. Mapped to physical pins of DM9000A 
--signal inter_ENET_DATA: std_logic_vector(15 downto 0);
signal inter_ENET_CMD,
	inter_ENET_RD_N,inter_ENET_WR_N,
	inter_ENET_CS_N,inter_ENET_RST_N,inter_ENET_INT, inter_ENET_INTHW: std_logic;

-- RAM is used to store data received from DM9000A PHY
type ram_type is array(0 to 165) of unsigned(15 downto 0) ;
signal RAM:ram_type:=(others=>(others=>'0'));
signal RAMarrayOffset:integer:=15;
signal ram_address : unsigned(9 downto 0);
--signal DMPHYInterruptFlag : std_logic := '1';
signal counter: unsigned(31 downto 0) := (others=>'0');
signal customHWInt : std_logic := '0';

-- signals below are used to communicate between dm9000_hw controller to both io_read_data and io_write module
signal	REG_IOR				: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal	REG_IOW				: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal	DATA				: STD_LOGIC_VECTOR(15 DOWNTO 0);	 
signal	READENABLE			: STD_LOGIC;							-- added for new design
signal	WRITEENABLE			: STD_LOGIC_VECTOR(1 DOWNTO 0);	
signal	EN					: STD_LOGIC_VECTOR(1 DOWNTO 0); 	

signal CLK_OFFSET_R			: STD_LOGIC_VECTOR (10 DOWNTO 0);
signal CLK_OFFSET_W			: STD_LOGIC_VECTOR (10 DOWNTO 0);
signal CLK_COUNTER_R		: STD_LOGIC_VECTOR (10 DOWNTO 0);	
signal CLK_COUNTER_W		: STD_LOGIC_VECTOR (10 DOWNTO 0);
signal 	DONE_IOR			: STD_LOGIC;
signal	DONE_IOW			: STD_LOGIC;
SIGNAL  INIT_DONE			: STD_LOGIC;
SIGNAL  ENT_IN				: STD_LOGIC;
SIGNAL  DOUT				: STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL  TMP_OUT				: STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL GP_o					: STD_LOGIC;
SIGNAL INT_umask			: STD_LOGIC;

constant ramLength: integer:=150;
signal ramIndexCounter1:integer:=0;
signal DONE_Reading_Packet: STD_LOGIC;
TYPE State_type IS(s0,s1,s2);
TYPE State_type1 IS(readS0,readS1,readS2);
SIGNAL 	nextState: State_type:=s0;
SIGNAL nState:State_type1:=readS0;


SIGNAL SWDoneRd : STD_LOGIC := '1';

signal messageCounter:integer:=0;

--
signal timeHwRead:std_logic_vector(31 downto 0);
signal timeSwHwRead:std_logic_vector(31 downto 0);
signal stateCounter:std_logic_vector(5 downto 0);
--begining of Architecture definition
begin
ram_address <= address(9 downto 0);
ENET_DATA  <= iDATA when (iWR_N='0' and sel='0') else 
							iDATA2 when (inter_ENET_WR_N='0' and sel='1') else	
							(others => 'Z');
				

process (clockInput)
	begin
	if rising_edge(clockInput) then
			if iRST_N = '0' then
				customHWInt <= '0';
			else
				if DONE_Reading_Packet= '1' then
					customHWInt <= '1';
					SWDoneRd <= '1';
				elsif iWR_N = '0' and iCS_N = '0' then
					if customHWInt = '1' then
						customHWInt <= '0'; -- important: reset the irq
						SWDoneRd <= '0';				
						ramIndexCounter1 <= 0;
					end if;
					elsif INT_umask = '0' then
					SWDoneRd <= '1';
				end if;
			end if; 

			
			
			if inter_ENET_CS_N = '0' then
				if inter_ENET_RD_N = '0' then
					if(ramIndexCounter1<=ramLength) then
						RAM(ramIndexCounter1+RAMarrayOffset)<= unsigned(oDATA2);
						ramIndexCounter1<=ramIndexCounter1+1;
					end if;
				end if;
			end if;
					

			if iRST_N = '0' then
				oDATA <= (others => '0');
			else
				if iCS_N = '0' then
					if iRD_N = '0' then
						oDATA <= std_logic_vector(RAM(to_integer(ram_address)));
						RAM(1) <= unsigned(oDATA2);
					elsif iWR_N = '0' then
						RAM(to_integer(ram_address)) <= unsigned(iDATA);
					end if;
				else
					--Read from the RAM here
					sel <= std_logic_vector(RAM(2))(0);
					if sel = '1' then 
						oINT <= customHWInt;
					else
						oINT <= inter_ENET_INT;
				    end if;
				
					RAM(3) <= unsigned(timeHwRead(15 downto 0));
					RAM(4) <= unsigned(timeHwRead(31 downto 16));
					RAM(5) <= unsigned(timeSwHwRead(15 downto 0));
					RAM(6) <= unsigned(timeSwHwRead(31 downto 16));



				end if;
			end if;
		end if;
end process;
							
process(sel, iCS_N, iRST_N, ENET_INT, inter_ENET_CMD, inter_ENET_CS_N, inter_ENET_RST_N)
begin	
	case sel is
		when '0'=> oDATA2<= ENET_DATA;
							ENET_CMD   <= std_logic(address(0));
							ENET_RD_N  <= iRD_N;
							ENET_WR_N <= iWR_N;
							ENET_CS_N <= iCS_N;
							ENET_RST_N <= iRST_N;
							inter_ENET_INT<=ENET_INT;
		when others =>
							oDATA2<=ENET_DATA;
							ENET_CMD   <= inter_ENET_CMD;
							ENET_RD_N  <= inter_ENET_RD_N;
							ENET_WR_N <= inter_ENET_WR_N;
							ENET_CS_N <= inter_ENET_CS_N;
							ENET_RST_N <= inter_ENET_RST_N;
							inter_ENET_INTHW<=ENET_INT;
	end case;
	
end process;

	MUX: multiplexer port map(
				s=>EN(0),
				mux_IO_read_data_ENET_CMD=>mux_IO_read_data_ENET_CMD,       
				mux_IO_read_data_ENET_CS_N=>mux_IO_read_data_ENET_CS_N,                                      
				mux_IO_read_data_ENET_WR_N=>mux_IO_read_data_ENET_WR_N,                                    
				mux_IO_read_data_ENET_RD_N=>mux_IO_read_data_ENET_RD_N,                                   
				mux_IO_read_data_ENET_RST_N=>mux_IO_read_data_ENET_RST_N,  
				iDATA2read=>iDATA2read,

				mux_IO_write_data_ENET_CMD=>mux_IO_write_data_ENET_CMD,          
				mux_IO_write_data_ENET_CS_N=>mux_IO_write_data_ENET_CS_N,                                        
				mux_IO_write_data_ENET_WR_N=>mux_IO_write_data_ENET_WR_N,                                         
				mux_IO_write_data_ENET_RD_N=>mux_IO_write_data_ENET_RD_N,                                         
				mux_IO_write_data_ENET_RST_N=>mux_IO_write_data_ENET_RST_N,                          
				iData2write=>iDATA2write,

				out_ENET_CMD=>inter_ENET_CMD,  
				out_ENET_CS_N=>inter_ENET_CS_N, 
				out_ENET_WR_N=>inter_ENET_WR_N, 
				out_ENET_RD_N=>inter_ENET_RD_N, 
				out_ENET_RST_N=>inter_ENET_RST_N, 
				iData2=>iData2
				);



read_data_reg : io_read_data port map(

	reg => REG_IOR,
	clk_offset=> CLK_OFFSET_R,
	clk_cnt =>  CLK_COUNTER_R,
	clk =>clockInput,
	readonly=> READENABLE,

	EN => EN(1),
	DM_IOW_n =>mux_IO_read_data_ENET_WR_N,
	DM_IOR_n =>mux_IO_read_data_ENET_RD_N,
	DM_CMD => mux_IO_read_data_ENET_CMD,
	DONE=>DONE_IOR,
	iDATA2 => iData2read,
	DM_CS=>mux_IO_read_data_ENET_CS_N,
	DM_RST_N=>mux_IO_read_data_ENET_RST_N
 );


write_data_reg:  io_write_data port map(
	reg => REG_IOW,
	data => DATA,
	clk_offset=>CLK_OFFSET_W,
	clk_cnt =>CLK_COUNTER_W,
	clk =>clockInput,
	writeOnly=> WRITEENABLE, 
	EN => EN(0),
	DM_IOW_n =>mux_IO_write_data_ENET_WR_N,
	DM_IOR_n =>mux_IO_write_data_ENET_RD_N,
	DM_CMD => mux_IO_write_data_ENET_CMD,
	DONE=>DONE_IOW,
	iDATA2 => iData2write,
	DM_CS=>mux_IO_write_data_ENET_CS_N,
	DM_RST_N=>mux_IO_write_data_ENET_RST_N
 );




custom_controller: dm9000_hw PORT MAP(

-- inputs
		CLK=>clockInput,
		DONE_IOR=>DONE_IOR,
		DONE_IOW=>DONE_IOW,
		INIT_DONE=> sel, --INIT_DONE,
		ENT_IN=> inter_ENET_INTHW,	--ENT_IN,				
		DOUT=>std_logic_vector(RAM(ramIndexCounter1-1+RAMarrayOffset)),		
		RX_length=>std_logic_vector(RAM(3+RAMarrayOffset)),
		RX_statusIn=>std_logic_vector(RAM(2+RAMarrayOffset)),
		
		SWDoneRd => SWDoneRd,
		INT_umask => INT_umask,
		-- outputs	
		REG_IOR	=>REG_IOR,
		REG_IOW	=>REG_IOW,
		DATA=>DATA,	 
		READENABLE	=>READENABLE,
		WRITEENABLE=>WRITEENABLE,	
		EN=>EN,
		TMP_OUT =>TMP_OUT,

		GP_o=>	GP_o,
		CLK_OFFSET_R	=>CLK_OFFSET_R,
		CLK_OFFSET_W	=>CLK_OFFSET_W,
		CLK_COUNTER_R	=>CLK_COUNTER_R,	
		CLK_COUNTER_W	=>CLK_COUNTER_W,
		DONE_Reading_Packet => DONE_Reading_Packet,
		s=>stateCounter			
);


debuging: debug_intermediate_signals_modules PORT MAP(

	RXbuffer0=>std_logic_vector(RAM(24+RAMarrayOffset)),
	RXbuffer1=>std_logic_vector(RAM(25+RAMarrayOffset)),
	RXbuffer2=>std_logic_vector(RAM(26+RAMarrayOffset)),
	RXbuffer3=>std_logic_vector(RAM(27+RAMarrayOffset)),
	RXbuffer4=>std_logic_vector(RAM(28+RAMarrayOffset)),
	RXbuffer5=>std_logic_vector(RAM(29+RAMarrayOffset)),
	RXbuffer6=>std_logic_vector(RAM(30+RAMarrayOffset)),
	messageCounter=>messageCounter,
	stateCounter=>stateCounter,
	timeHwRead=>timeHwRead,
	timeSwHwRead=>timeSwHwRead,
	clk=>clockInput
 );
	
end behavior;
 
