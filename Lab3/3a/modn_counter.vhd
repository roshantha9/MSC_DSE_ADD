----------------------------------------------------------------------------------
-- Company: 			UoY-Elec
-- Engineer: 			106033467
-- 
-- Create Date:    		18:36:20 02/03/2011 
-- Design Name: 	 	mod-n up counter
-- Module Name:    		modn_counter - Behavioral 
-- Project Name:   		Lab3a
-- Target Devices: 		XUPV5-LX110T - Virtex 5
-- Tool versions: 		ISE 10.1
-- Description: An Up Counter, with a synchronous RESET, CLOCK ENABLE, and
--				most importantly a maximum/overflow value. Sets MAX_FLAG, to
--				true, when the overflow value has been reached. Counts from 0 to n
--
-- Dependencies: None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Design adapted from :
--						P. P. Chu, RTL hardware design using VHDL:
--						coding for efficiency, portability and scalability,
--						Wiley-IEEE Press, 2006
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------
-- Entity Declaration
----------------------------------------------------------------------------------
entity modn_counter is
	generic( n 		    : NATURAL := 5;	 -- mod-n (max value)
			 bit_width  : NATURAL := 3 	 -- size of the count output
										 --	(has to fit the max value as well)
			);
	port(	
			-- inputs
			CLK, RESET 	: in STD_LOGIC;			-- clock, reset
			EN 		  	: in STD_LOGIC;			-- count enable
			
			-- outputs
			-- current counter reg value
			COUNT 	  	: out STD_LOGIC_VECTOR(bit_width-1 downto 0);-
			MAX_FLAG   	: out STD_LOGIC			-- max val reached flag		
		);			

end modn_counter;

architecture architectural of modn_counter is
	
	-- count register
	signal reg 		: STD_LOGIC_VECTOR(bit_width-1 downto 0);	
	-- temp signal used to hold Max Val in binary
	signal max_val 	: STD_LOGIC_VECTOR(bit_width-1 downto 0);
	
begin
	
	max_val <= conv_std_logic_vector(n-1, bit_width);
	
	
----------------------------------------------------------------------------------
-- Main Process block - inferring an up counter and comparator
----------------------------------------------------------------------------------	
	-- counter behaviour
	-- with synchronous reset, and clock enable
	p_reg1: process(CLK)
	begin
		-- on a rising edge of the clock
		if CLK='1' and CLK'event then
			-- synchronous reset
			if RESET='1' then 
				reg <= (others => '0');
			elsif EN='1' then
				-- compare current with max value
				if(reg=max_val) then
					reg <= (others => '0');
				else
					-- increment the current value of the reg
					reg <= reg + 1;
				end if;
			end if;
		end if;				
	end process p_reg1;	

----------------------------------------------------------------------------------
-- Set MAX flag when overflow value has been reached
----------------------------------------------------------------------------------	
	-- outputs : count and the max tick
	COUNT <= reg;
	MAX_FLAG <= '1' when (reg=max_val) else '0';

end architectural;

