----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     18:53:12 01/28/2011 
-- Design Name:      fibonacci controller
-- Module Name:     fib_control - Behavioral 
-- Project Name:    Lab2c
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     FSM Controller of the Fibonacci sequence generator
--
-- Dependencies:    None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity fib_control is
	generic ( ram_adr_size : NATURAL := 4 );
	port(	
			-- inputs --
			CLOCK 	: in STD_LOGIC;
			COUNT_IN : in STD_LOGIC;			
			RESET 	: in STD_LOGIC;
			MAX_FIB_REACHED : in STD_LOGIC;
			
			-- outputs --
			PR_STATE : out STD_LOGIC_VECTOR(2 downto 0); -- present state of the fsm
			RAM_WR_EN : out STD_LOGIC;					 -- ram write enable signal	
			-- ram read, write address
			RAM_RD_ADDR : out STD_LOGIC_VECTOR(ram_adr_size-1 downto 0);	
			RAM_WR_ADDR : out STD_LOGIC_VECTOR(ram_adr_size-1 downto 0)			
	);	

end fib_control;

architecture behavioral of fib_control is

	-- total number of tates
	type state is (s0, s1, s2, s3, s4, s5);
	
	signal cur_state : state;	
	signal tmp_ram_rd_addr : STD_LOGIC_VECTOR(ram_adr_size-1 downto 0);	-- ram read address
	signal tmp_ram_wr_addr : STD_LOGIC_VECTOR(ram_adr_size-1 downto 0);	-- ram write address
	signal tmp_ram_wr_en : STD_LOGIC;	
	signal internal_reset : STD_LOGIC;	-- internal reset for the rd/wr counters	

begin
	
	-- Present state output
	PR_STATE <= "000" when cur_state=s0 else
				"001" when cur_state=s1 else
				"010" when cur_state=s2 else
				"011" when cur_state=s3 else
				"100" when cur_state=s4 else
				"101" when cur_state=s5 else "111";
	
----------------------------------------------------------------------------------
-- STATE MACHINE
----------------------------------------------------------------------------------
	
	-- Determine next state in the FSM
	fsm_nxtstate: process is
	begin		
			wait until rising_edge(CLOCK);
			if (RESET='1') then 	-- Globacl RESET signal
				cur_state <= s0;
			else
				case cur_state is
					
					-- if COUNT is pressed, go to s1 and computer the first
					-- FN. Otherwise wait in s0
					when s0 =>						
						if(COUNT_IN='1') then
							cur_state <= s1;
						else
							cur_state <= s0;
						end if;								
						
					-- if COUNT is pressed, go to s2, otherwise
					-- wait in s1					
					when s1 =>
					
						if(COUNT_IN='1') then
								cur_state <= s2;
							else
								cur_state <= s1;
							end if;
					
					-- if COUNT is pressed, go to s3, 
					-- if max fibonacci number is reached, then
					-- go to s0 (sort of like a reset)
					-- otherwise wait in s3. 
					when s2 =>
							if(COUNT_IN='1') then
								if(MAX_FIB_REACHED='1') then
									cur_state <= s0;
								else							
									cur_state <= s3;
								end if;							
							else
								cur_state <= s2;
							end if;			
										
					-- go directly to s4
					when s3 =>			
						cur_state <= s4;					
					-- go directly to s5
					when s4 =>				
						cur_state <= s5;					
					-- go back to s2
					when s5 =>
						cur_state <= s2;					
					when others => 
						cur_state <= s0;
					
				end case;			
		end if;
		
	end process fsm_nxtstate;	
	
	-- write enable in S1 and S5
	tmp_ram_wr_en <= '1' when (cur_state = s1 or 
							   cur_state = s5)
						 else '0';	
	
	internal_reset <= '1' when cur_state=s0 else '0';
	
	-- assign control outputs
	RAM_WR_EN 	<= tmp_ram_wr_en;	
	RAM_WR_ADDR <= tmp_ram_wr_addr;	
	RAM_RD_ADDR <= tmp_ram_rd_addr;
	
	
----------------------------------------------------------------------------------
-- RAM READ ADDRESS POINTER
----------------------------------------------------------------------------------
	
	-- this increments the read address pointer
	-- (up counter, synch reset, clock enable)
	p_rdaddrpointer: process is
	begin
		wait until rising_edge(CLOCK);			
		if (RESET='1' or internal_reset='1') then
			tmp_ram_rd_addr <= (others => '0');
		else
			-- only increment if state is s3
			if (cur_state=s3) then
				tmp_ram_rd_addr <= tmp_ram_rd_addr+1;
			else
				tmp_ram_rd_addr <= tmp_ram_rd_addr;
			end if;				
		end if;
	end process fsm_p1;	
	
----------------------------------------------------------------------------------
-- RAM WRITE ADDRESS POINTER
----------------------------------------------------------------------------------
	-- this increments the write address pointer
	-- (up counter, synch reset, clock enable)
	p_wraddrpointer: process is
	begin
		wait until rising_edge(CLOCK);				
		if (RESET='1' or internal_reset='1') then
			tmp_ram_wr_addr <= (0=>'1', others => '0');
		else
			-- only increment if state is s4
			if (cur_state=s4) then
				tmp_ram_wr_addr <= tmp_ram_wr_addr+1;
			else
				tmp_ram_wr_addr <= tmp_ram_wr_addr;
			end if;				
		end if;		
	end process fsm_p2;
	
end behavioral;

