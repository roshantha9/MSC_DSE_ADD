----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     16:38:54 01/28/2011 
-- Design Name:     Switch Debounce circuit - 1 input
-- Module Name:     debounce - Behavioral 
-- Project Name:    Lab2b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Debounce logic, waits for 3 clock cycles
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

entity debounce is
 Port ( D_IN  : in STD_LOGIC;
	    CLOCK : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
		Q_OUT : out  STD_LOGIC );
end debounce;

architecture behavioral of debounce is
	
	-- 4 flip flops
	signal Q1, Q2, Q3, Q4 : STD_LOGIC;	

begin

-- inferring 4 , 1-bit registers (dffs)
process(CLOCK, RESET)
begin
   if (CLOCK'event and CLOCK='1') then
      if (RESET = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0';
		 Q4 <= '0';
      else
         Q1 <= D_IN;	-- bouncy input signal
         Q2 <= Q1;
         Q3 <= Q2;
		 Q4 <= Q3;
      end if;
   end if;
end process;
 
-- waits for a 3 clock cycle length pulse
Q_OUT <= Q1 and Q2 and Q3 and (not Q4);

end behavioral;

