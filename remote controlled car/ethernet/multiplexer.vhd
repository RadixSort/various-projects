library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexer is
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
end multiplexer;

architecture rtl_comb of multiplexer is


signal sel:std_logic;
begin
	-- s=1 select IO_write_data signals
	-- s=0 select IO_read_data signals
	
mux2_1_CMD: entity work.multiplexer_2_1 port map (
		in0=>mux_IO_read_data_ENET_CMD,
		in1=>mux_IO_write_data_ENET_CMD,
		s=>s, 
		z=>out_ENET_CMD
);


mux2_1_CS_N: entity work.multiplexer_2_1 port map (
		in0=>mux_IO_read_data_ENET_CS_N,
		in1=>mux_IO_write_data_ENET_CS_N,
		s=>s, 
		z=>out_ENET_CS_N
);

mux2_1_WR_N: entity work.multiplexer_2_1 port map (
		in0=>mux_IO_read_data_ENET_WR_N,
		in1=>mux_IO_write_data_ENET_WR_N,
		s=>s, 
		z=>out_ENET_WR_N
);

mux2_1_RD_N: entity work.multiplexer_2_1 port map (
		in0=>mux_IO_read_data_ENET_RD_N,
		in1=>mux_IO_write_data_ENET_RD_N,
		s=>s, 
		z=>out_ENET_RD_N
);


mux2_1_RST_N: entity work.multiplexer_2_1 port map (
		in0=>mux_IO_read_data_ENET_RST_N,
		in1=>mux_IO_write_data_ENET_RST_N,
		s=>s, 
		z=>out_ENET_RST_N
);

mux2_1_iData2: entity work.multiplexer_2_1_data port map (
		in0=>iData2read,
		in1=>iData2write,
		s=>s, 
		z=>iData2
);


end rtl_comb;