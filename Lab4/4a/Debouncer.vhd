---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	23:19:13 02/06/2010 
-- Design Name:   	Debouncer
-- Module Name:   	Debouncer - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Signal propagates through 3 flip flops, gives a 
--					2 clock cycle delayed one shot output
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
-- Eneity declaration
----------------------------------------------------------------------------------

entity Debouncer is
    Port ( CLK : in  STD_LOGIC;
           Sig : in  STD_LOGIC;
           Deb_Sig : out  STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is

	signal Q0, Q1, Q2 : STD_LOGIC := '0';
	
begin

----------------------------------------------------------------------------------
-- MAIN PROCESS BLOCK : infers 3 dffs
----------------------------------------------------------------------------------

process (CLK) is
begin
	if (CLK'event and CLK = '1') then 
		Q0 <= Sig;
		Q1 <= Q0;
		Q2 <= Q1;
	end if;
end process;

Deb_Sig <= Q0 and Q1 and (not Q2);

end Behavioral;

