library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity notes_drawer is
generic(
    pixel_buffer_base : std_logic_vector := x"00080000"
	 );
port (
    clk: in std_logic;
    reset_n: in std_logic;
    slave_addr: in std_logic_vector(2 downto 0);
    slave_rd_en: in std_logic;
    slave_wr_en: in std_logic;
    slave_readdata: out std_logic_vector(31 downto 0);
    slave_writedata: in std_logic_vector(31 downto 0);
    master_addr : out std_logic_vector(31 downto 0);
    master_rd_en : out std_logic;
    master_wr_en : out std_logic;
    master_be : out std_logic_vector(1 downto 0);
    master_readdata : in std_logic_vector(15 downto 0);
    master_writedata: out  std_logic_vector(15 downto 0);
    master_waitrequest : in std_logic);
end notes_drawer;

architecture rtl of notes_drawer is
    signal notes : std_logic_vector(7 downto 0) := "00000000";
	 signal everything_done : std_logic := '0';
	 signal hitbox_yes : std_logic_vector(7 downto 0);
	 
	 --these two arrays hold the x an y coordinates of the falling notes
	 type x_array is array (0 to 239) of std_logic_vector(8 downto 0); 
	 signal notes_x_coord : x_array := (others=> (others=>'0'));
	 type y_array is array (0 to 239) of std_logic_vector(7 downto 0); 
	 signal notes_y_coord : y_array := (others=> (others=>'0'));
	 
--	 constant pixel_buffer_base : std_logic_vector(31 downto 0) :=  x"00080000";
	 
begin

	-- This process grabs what is in the notes signal, and sets the x1,x2,y1,y2, and colour signals accordingly so the other process can draw the box
	-- Process advances the notes down every 5 ms
	process(clk, reset_n, notes)
	
		--notes_x_coord <= (others=> (others=>'0'));
		--notes_y_coord <= (others=> (others=>'0'));
		variable x1_local,x2_local : std_logic_vector(8 downto 0);
		variable y1_local,y2_local : std_logic_vector(7 downto 0);
		variable colour_local : std_logic_vector(15 downto 0) := "0000000000000000";	
		variable notes_local : std_logic_vector(7 downto 0);
		
		variable box_done : std_logic := '1';
		variable draw_done : std_logic := '1';
		
		-- This is used to remember the left-most x point as we draw the box.
		variable savedx : std_logic_vector(8 downto 0);
		variable processing : bit := '0';  -- Used to indicate whether we are drawing
		variable state : integer;          -- Current state.  We could use enumerated types.
		variable black_bar_yes : integer;
		
		variable i : integer := 0;
		variable j : integer := 0;
		variable counter: integer :=0;
		
		begin
			if (reset_n = '0') then
				master_wr_en<= '0';
				master_rd_en<= '0';
				notes <= "00000000";
				processing := '0';
				state := 0;
				box_done := '0';
				everything_done <= '0';
				counter := 0;
				i := 0;
				j := 0;
				notes_x_coord <= (others=> (others=>'0'));
				notes_y_coord <= (others=> (others=>'0'));

			elsif rising_edge(clk) then
				
				counter := counter + 1;
				
				--step through note management portion if we aren't actively recieving notes
				if( everything_done = '0') then
					
					--grabs what's in the notes signal, in case anything changes
					notes_local := notes;
					
					--don't do anything unless we know we have new notes to add to the screen
								
					if(notes_local(0) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "000101001";
					 j := j + 1;
					end if;
					if(notes_local(1) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "000111000";
					 j := j + 1;
					end if;
					if(notes_local(2) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "001000111";
					 j := j + 1;
					end if;
					if(notes_local(3) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "001010110";
					 j := j + 1;
					end if;
					if(notes_local(4) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "001100101";
					 j := j + 1;
					end if;
					if(notes_local(5) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "001110100";
					 j := j + 1;
					end if;
					if(notes_local(6) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "010000011";
					 j := j + 1;
					end if;
					if(notes_local(7) = '1') then
					 notes_y_coord(j) <= "00000000";
					 notes_x_coord(j) <= "010010010";
					 j := j + 1;
					end if;
				
					everything_done <= '1';
						
						-- By the time we get to the end of the array, the first elements at the smaller indices are assumed to have fallen, reset j
						-- back to 0 and write over the first elements with more notes
					if( j = 239) then	
						j := 0;
					end if;
								
				end if;
				
				if ( counter = 183500) then --advance notes every ~25ms
					processing := '1';  -- start drawing on next rising clk edge
               state := 0;
					draw_done := '0'; --indicate that we have to go through the array and send it all to the pixel buffer 
					box_done := '1';
					i := 0;
					counter := 0; -- reset our ~25 ms counter
				end if;
				
				if (draw_done = '0') then
					if( box_done = '1' ) then
						box_done := '0';
						--grab the next box to draw if ready
						x1_local := notes_x_coord(i);
						y1_local := notes_y_coord(i);
						if( x1_local = "000000000") then
							colour_local := "0000000000000000";
						elsif( x1_local = "000101001" ) then
							colour_local := "1000111100000000";  --lime colour
						elsif( x1_local = "000111000") then
							colour_local := "1111000000000000"; --red
						elsif (x1_local = "001000111") then
							colour_local := "1111111110110000"; --yelllow
						elsif( x1_local = "001010110") then
							colour_local := "0000000000011111"; --blue
						elsif( x1_local = "001100101") then
							colour_local := "0000011111100000"; -- green
						elsif( x1_local = "001110100") then
							colour_local := "1111000011110000"; --pink
						elsif( x1_local = "000111000") then
							colour_local := "1111101000000000"; -- orange
						elsif( x1_local = "010010010") then
							colour_local := "0000111100001111"; -- cyan
						end if;
						--reset the notes if they are at the bottom
						if( y1_local /= "11111010") then
							notes_y_coord(i) <= std_logic_vector(unsigned(notes_y_coord(i)) + 1);
						end if;	
						x2_local := std_logic_vector(unsigned(x1_local) + 13);
						y2_local := std_logic_vector(unsigned(y2_local) + 5); 
						savedx := x1_local;
						i := i + 1;
						
						black_bar_yes := 1;
						
						end if;
					
					if( savedx /= "000000000" and state = 0 and box_done = '0' and black_bar_yes = 1) then
					--this state is for drawing the bar of black pixels above the box as it moves down
						master_addr <= std_logic_vector(unsigned(pixel_buffer_base) +
 						                   unsigned( std_logic_vector(unsigned(y1_local) - 1) & x1_local & '0'));	
                  master_writedata <= "0000000000000000";
                  master_be <= "11";  -- byte enable
                  master_wr_en <= '1';
                  master_rd_en <= '0';
						
						state:= 1;
						
					elsif ( savedx /= "000000000" and state = 1 and master_waitrequest = '0' and black_bar_yes = 1) then
                  master_wr_en  <= '0';
                  state := 0;
                  if (x1_local = x2_local) then
                        x1_local := savedx;
                        --no need to increment y1_local since we were drawing above the top of the box here
								black_bar_yes := 0; -- we're done drawing the black bar, move on to the box	
                  else 
                        x1_local := std_logic_vector(unsigned(x1_local)+1);
                  end if;			
					-------------------------------	0
					elsif ( savedx /= "000000000" and state = 0 and box_done = '0') then	  				   	          
                  master_addr <= std_logic_vector(unsigned(pixel_buffer_base) +
 						                   unsigned( y1_local & x1_local & '0'));	
                  master_writedata <= colour_local;
                  master_be <= "11";  -- byte enable
                  master_wr_en <= '1';
                  master_rd_en <= '0';
                  state := 1; -- on the next rising clock edge, do state 1 operations

               -- After starting a write operation, we need to wait until
               -- master_waitrequest is 0.  If it is 1, stay in state 1.

               elsif (savedx /= "000000000" and state = 1 and master_waitrequest = '0') then
                  master_wr_en  <= '0';
                  state := 0;
                  if (x1_local = x2_local) then
                        x1_local := savedx;
                        --no need to increment y1_local since we were drawing above the top of the box here
								state := 2; -- we're done drawing the black bar, move on to the box	
                  else 
                        x1_local := std_logic_vector(unsigned(x1_local)+1);
                  end if;		
					------------------------------------------------------- 1
					elsif ( savedx /= "000000000" and state = 2 and box_done = '0') then	  				   	          
               master_addr <= std_logic_vector(unsigned(pixel_buffer_base) +
 						                   unsigned( std_logic_vector(unsigned(y1_local) + 1) & x1_local & '0'));	
               master_writedata <= colour_local;
					master_be <= "11";  -- byte enable
               master_wr_en <= '1';
               master_rd_en <= '0';
               state := 3; -- on the next rising clock edge, do state 1 operations

               -- After starting a write operation, we need to wait until
               -- master_waitrequest is 0.  If it is 1, stay in state 1.

               elsif (savedx /= "000000000" and state = 3 and master_waitrequest = '0') then
                  master_wr_en  <= '0';
                  state := 2;
                  if (x1_local = x2_local) then
                        x1_local := savedx;
                        --no need to increment y1_local 
								state := 4; -- we're done drawing the black bar, move on to the box	
                  else 
                        x1_local := std_logic_vector(unsigned(x1_local)+1);
								
						end if;						
					---------------------------------------- 2
					elsif ( savedx /= "000000000" and state = 4 and box_done = '0') then	  				   	          
               master_addr <= std_logic_vector(unsigned(pixel_buffer_base) +
 						                   unsigned( std_logic_vector(unsigned(y1_local) + 2) & x1_local & '0'));	
               master_writedata <= colour_local;
					master_be <= "11";  -- byte enable
               master_wr_en <= '1';
               master_rd_en <= '0';
               state := 5; -- on the next rising clock edge, do state 1 operations

               -- After starting a write operation, we need to wait until
               -- master_waitrequest is 0.  If it is 1, stay in state 1.

               elsif (savedx /= "000000000" and state =5 and master_waitrequest = '0') then
                  master_wr_en  <= '0';
                  state := 4;
                  if (x1_local = x2_local) then
                        x1_local := savedx;
                        --no need to increment y1_local 
								state := 6; -- we're done drawing the black bar, move on to the box	
                  else 
                        x1_local := std_logic_vector(unsigned(x1_local)+1);
								
						end if;						
					---------------------------------------- 3
					elsif ( savedx /= "000000000" and state = 6 and box_done = '0') then	  				   	          
               master_addr <= std_logic_vector(unsigned(pixel_buffer_base) +
 						                   unsigned( std_logic_vector(unsigned(y1_local) + 3) & x1_local & '0'));	
               master_writedata <= colour_local;
					master_be <= "11";  -- byte enable
               master_wr_en <= '1';
               master_rd_en <= '0';
               state := 7; -- on the next rising clock edge, do state 1 operations

               -- After starting a write operation, we need to wait until
               -- master_waitrequest is 0.  If it is 1, stay in state 1.

               elsif (savedx /= "000000000" and state = 7 and master_waitrequest = '0') then
                  master_wr_en  <= '0';
                  state := 6;
                  if (x1_local = x2_local) then
                        x1_local := savedx;
                        --no need to increment y1_local 
								state := 0; -- we're done drawing the black bar, move on to the box	
								box_done := '1';
                  else 
                        x1_local := std_logic_vector(unsigned(x1_local)+1);
								
						end if;						
					---------------------------------------- 4
               end if;
					
					--if we've drawn all the boxes, set the variable to reflect that and reset i.
					if( i = 239) then
						i := 0;
						draw_done := '1';
					end if;
				end if;
				
				 -- We should also check if there is a write on the slave bus.  If so, copy the
             -- written value into one of our internal registers. TO CLARIFY: THIS IS THE NIOS
				 -- SENDING US SHIT OVER THE SLAVE INTERFACE.
				if (slave_wr_en = '1') then
					case slave_addr is
						-- These four should be self-explantory
						when "000" => notes <= slave_writedata(7 downto 0);
						-- when "001" => y1 <= slave_writedata(7 downto 0);
						-- when "010" => x2 <= slave_writedata(8 downto 0);
						-- when "011" => y2 <= slave_writedata(7 downto 0);
						-- when "100" => colour <= slave_writedata(15 downto 0);

						-- If the user tries to write to offset 5, we are to start drawing
						when "101" =>
							everything_done <= '0';
						when others => null;
					end case;
				end if;
			end if;
	end process;
	
   -- This process is used to describe what to do when a “read” operation occurs on the
   -- slave interface (this is because the C program does a memory read).  Depending
   -- on the address read, we return x1, x2, y1, y2, the colour, or the done flag.

   process (slave_rd_en, slave_addr, everything_done)
   begin	       
      slave_readdata <= (others => '-');
      if (slave_rd_en = '1') then
          case slave_addr is
					--slave_addr is the offset from the drawer base specified in C code
              when "000" => slave_readdata <= "000000000000000000000000" & notes;
              when "001" => slave_readdata <= "000000000000000000000000" & hitbox_yes;
              when "010" => slave_readdata <= "00000000000000000000000000000000"; 
              when "011" => slave_readdata <= "00000000000000000000000000000000"; 
              when "100" => slave_readdata <= "00000000000000000000000000000000"; 
              when "101" => slave_readdata <= (0=>everything_done, others=>'0');
              when others => null;
            end case;
		end if;
	end process;										
end rtl;
