---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	17:14:58 02/17/2011 
-- Design Name:    	Shift Left N unit
-- Module Name:    	shiftleftN - Behavioral 
-- Project Name:   	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Shift left a given bit vector by N bits, where N is between
--					0 and 31
--
-- Dependencies: 	None
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

----------------------------------------------------------------------------------
-- Entity Declaration
-- Both the inputs are of the same length, but only the 32 LSBs are being used.
-- Both inputs are expected to be 64 bits.
----------------------------------------------------------------------------------
entity shiftleftN is
	generic( width : natural := 64 );
	port	(
				SHL_in_A	: in STD_LOGIC_VECTOR(width-1 downto 0);
				
				-- N has to be a power of 2 (i.e 2^N)
				SHL_in_N : in STD_LOGIC_VECTOR(width-1 downto 0);
				
				SHL_out_RESULT : out STD_LOGIC_VECTOR(width-1 downto 0)
			);
end shiftleftN;

architecture Behavioral of shiftleftN is

	-- temporary signal used to padd zeros
	signal tmpz2 : STD_LOGIC_VECTOR(width-1 downto 0);

begin

----------------------------------------------------------------------------------
-- The bellow will hopefully infer a large mux, with 32 wide select line
-- and 64 bit input.
-- The output is padded with zeros to make a 64-bit output. Hence no overflows
-- need to be handled (for a 32 bit input A - exxtended to 64 bits)
----------------------------------------------------------------------------------	
	
	tmpz2 <= (others => '0');
	
SHL_out_RESULT  <= 	SHL_in_A when (SHL_in_N(0) = '1')  else 	-- no shift	
					(SHL_in_A(width-2 downto 0) & tmpz2(0)) when (SHL_in_N(1) = '1')  else														
					(SHL_in_A(width-3 downto 0) & tmpz2(width-1 downto width-2)) 	when (SHL_in_N(2) = '1')  else			
					(SHL_in_A(width-4 downto 0) & tmpz2(width-1 downto width-3)) 	when (SHL_in_N(3) = '1')  else	
					(SHL_in_A(width-5 downto 0) & tmpz2(width-1 downto width-4)) 	when (SHL_in_N(4) = '1')  else
					(SHL_in_A(width-6 downto 0) & tmpz2(width-1 downto width-5)) 	when (SHL_in_N(5) = '1')  else	
					(SHL_in_A(width-7 downto 0) & tmpz2(width-1 downto width-6)) 	when (SHL_in_N(6) = '1')  else
					(SHL_in_A(width-8 downto 0) & tmpz2(width-1 downto width-7)) 	when (SHL_in_N(7) = '1')  else	
					(SHL_in_A(width-9 downto 0) & tmpz2(width-1 downto width-8)) 	when (SHL_in_N(8) = '1')  else	
					(SHL_in_A(width-10 downto 0) & tmpz2(width-1 downto width-9)) 	when (SHL_in_N(9) = '1')  else
					(SHL_in_A(width-11 downto 0) & tmpz2(width-1 downto width-10)) 	when (SHL_in_N(10) = '1')  else
					(SHL_in_A(width-12 downto 0) & tmpz2(width-1 downto width-11)) 	when (SHL_in_N(11) = '1')  else
					(SHL_in_A(width-13 downto 0) & tmpz2(width-1 downto width-12)) 	when (SHL_in_N(12) = '1')  else
					(SHL_in_A(width-14 downto 0) & tmpz2(width-1 downto width-13)) 	when (SHL_in_N(13) = '1')  else
					(SHL_in_A(width-15 downto 0) & tmpz2(width-1 downto width-14)) 	when (SHL_in_N(14) = '1')  else
					(SHL_in_A(width-16 downto 0) & tmpz2(width-1 downto width-15)) 	when (SHL_in_N(15) = '1')  else
					(SHL_in_A(width-17 downto 0) & tmpz2(width-1 downto width-16)) 	when (SHL_in_N(16) = '1')  else
					(SHL_in_A(width-18 downto 0) & tmpz2(width-1 downto width-17)) 	when (SHL_in_N(17) = '1')  else
					(SHL_in_A(width-19 downto 0) & tmpz2(width-1 downto width-18)) 	when (SHL_in_N(18) = '1')  else
					(SHL_in_A(width-20 downto 0) & tmpz2(width-1 downto width-19)) 	when (SHL_in_N(19) = '1')  else
					(SHL_in_A(width-21 downto 0) & tmpz2(width-1 downto width-20)) 	when (SHL_in_N(20) = '1')  else
					(SHL_in_A(width-22 downto 0) & tmpz2(width-1 downto width-21)) 	when (SHL_in_N(21) = '1')  else
					(SHL_in_A(width-23 downto 0) & tmpz2(width-1 downto width-22)) 	when (SHL_in_N(22) = '1')  else
					(SHL_in_A(width-24 downto 0) & tmpz2(width-1 downto width-23)) 	when (SHL_in_N(23) = '1')  else
					(SHL_in_A(width-25 downto 0) & tmpz2(width-1 downto width-24)) 	when (SHL_in_N(24) = '1')  else
					(SHL_in_A(width-26 downto 0) & tmpz2(width-1 downto width-25)) 	when (SHL_in_N(25) = '1')  else
					(SHL_in_A(width-27 downto 0) & tmpz2(width-1 downto width-26)) 	when (SHL_in_N(26) = '1')  else
					(SHL_in_A(width-28 downto 0) & tmpz2(width-1 downto width-27)) 	when (SHL_in_N(27) = '1')  else
					(SHL_in_A(width-29 downto 0) & tmpz2(width-1 downto width-28)) 	when (SHL_in_N(28) = '1')  else
					(SHL_in_A(width-30 downto 0) & tmpz2(width-1 downto width-29)) 	when (SHL_in_N(29) = '1')  else
					(SHL_in_A(width-31 downto 0) & tmpz2(width-1 downto width-30)) 	when (SHL_in_N(30) = '1')  else
					(SHL_in_A(0) & tmpz2(width-1 downto width-30));		
																			

end Behavioral;

