----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	19:53:44 01/27/2011 
-- Design Name: 	1-bit Full Adder
-- Module Name:    	fa - Behavioral 
-- Project Name:   	Lab2a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	1-bit Full Adder
--
-- Dependencies: 	None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------------
-- Declaration of entity fa
entity fa is
   port (FA_in_X, FA_in_Y, FA_in_CIN   : in  STD_LOGIC;
		   FA_out_SUM, FA_out_COUT       : out STD_LOGIC);
end fa;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Structural (using combinational logic) Implementation of Full Adder circuit
architecture behavioural of fa is
begin

	FA_out_SUM  <= (FA_in_X XOR FA_in_Y) XOR FA_in_CIN;
	FA_out_COUT <= (FA_in_X AND FA_in_Y) OR (FA_in_CIN AND (FA_in_X XOR FA_in_Y));
	
end behavioural;
---------------------------------------------------------------------------
