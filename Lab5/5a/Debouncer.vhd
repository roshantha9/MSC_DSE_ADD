----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     16:38:54 01/28/2011 
-- Design Name:     Switch Debounce circuit - 1 input
-- Module Name:     debounce - Behavioral 
-- Project Name:    Lab5a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Debounce logic
--
-- Dependencies:    
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
----------------------------------------------------------------------------------
entity Debouncer is
    Port ( CLK 		: in  STD_LOGIC;
           Sig 		: in  STD_LOGIC;
           Deb_Sig 	: out  STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is

	signal Q0, Q1, Q2 : STD_LOGIC := '0';
	
begin

----------------------------------------------------------------------------------
-- inferring 3 1-bit registers (dffs)
----------------------------------------------------------------------------------
-- connecting the FFs in series
process (CLK) is
begin
	if (CLK'event and CLK = '1') then 
		Q0 <= Sig;
		Q1 <= Q0;
		Q2 <= Q1;
	end if;
end process;

----------------------------------------------------------------------------------
-- produce the debounced output
-- basically a signal which checks if the input is high
-- for 2 clock cycles.
--------------------------------------------------------------------------------
Deb_Sig <= Q0 and Q1 and (not Q2);

end Behavioral;

