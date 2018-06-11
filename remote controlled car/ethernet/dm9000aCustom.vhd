--Legal Notice: (C)2007 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dm9000aCustom is 
        port (
              -- inputs:
                 signal ENET_INT : IN STD_LOGIC;
                 signal address : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
                 signal clockInput : IN STD_LOGIC;
                 signal enableSignal : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal iCS_N : IN STD_LOGIC;
                 signal iDATA : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal iRD_N : IN STD_LOGIC;
                 signal iRST_N : IN STD_LOGIC;
                 signal iWR_N : IN STD_LOGIC;

              -- outputs:
                 signal ENET_CMD : OUT STD_LOGIC;
                 signal ENET_CS_N : OUT STD_LOGIC;
                 signal ENET_DATA : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ENET_RD_N : OUT STD_LOGIC;
                 signal ENET_RST_N : OUT STD_LOGIC;
                 signal ENET_WR_N : OUT STD_LOGIC;
                 signal oDATA : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal oINT : OUT STD_LOGIC
              );
end entity dm9000aCustom;


architecture europa of dm9000aCustom is
component dm9000a is 
           port (
                 -- inputs:
                    signal ENET_INT : IN STD_LOGIC;
                    signal address : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
                    signal clockInput : IN STD_LOGIC;
                    signal enableSignal : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal iCS_N : IN STD_LOGIC;
                    signal iDATA : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal iRD_N : IN STD_LOGIC;
                    signal iRST_N : IN STD_LOGIC;
                    signal iWR_N : IN STD_LOGIC;

                 -- outputs:
                    signal ENET_CMD : OUT STD_LOGIC;
                    signal ENET_CS_N : OUT STD_LOGIC;
                    signal ENET_DATA : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ENET_RD_N : OUT STD_LOGIC;
                    signal ENET_RST_N : OUT STD_LOGIC;
                    signal ENET_WR_N : OUT STD_LOGIC;
                    signal oDATA : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal oINT : OUT STD_LOGIC
                 );
end component dm9000a;

                signal internal_ENET_CMD :  STD_LOGIC;
                signal internal_ENET_CS_N :  STD_LOGIC;
                signal internal_ENET_RD_N :  STD_LOGIC;
                signal internal_ENET_RST_N :  STD_LOGIC;
                signal internal_ENET_WR_N :  STD_LOGIC;
                signal internal_oDATA :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_oINT :  STD_LOGIC;

begin

  --the_dm9000a, which is an e_instance
  the_dm9000a : dm9000a
    port map(
      ENET_CMD => internal_ENET_CMD,
      ENET_CS_N => internal_ENET_CS_N,
      ENET_DATA => ENET_DATA,
      ENET_RD_N => internal_ENET_RD_N,
      ENET_RST_N => internal_ENET_RST_N,
      ENET_WR_N => internal_ENET_WR_N,
      oDATA => internal_oDATA,
      oINT => internal_oINT,
      ENET_INT => ENET_INT,
      address => address,
      clockInput => clockInput,
      enableSignal => enableSignal,
      iCS_N => iCS_N,
      iDATA => iDATA,
      iRD_N => iRD_N,
      iRST_N => iRST_N,
      iWR_N => iWR_N
    );


  --vhdl renameroo for output signals
  ENET_CMD <= internal_ENET_CMD;
  --vhdl renameroo for output signals
  ENET_CS_N <= internal_ENET_CS_N;
  --vhdl renameroo for output signals
  ENET_RD_N <= internal_ENET_RD_N;
  --vhdl renameroo for output signals
  ENET_RST_N <= internal_ENET_RST_N;
  --vhdl renameroo for output signals
  ENET_WR_N <= internal_ENET_WR_N;
  --vhdl renameroo for output signals
  oDATA <= internal_oDATA;
  --vhdl renameroo for output signals
  oINT <= internal_oINT;

end europa;

