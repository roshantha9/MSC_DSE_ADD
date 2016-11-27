----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	19:17:02 02/17/2011
-- Design Name:    	shiftleftN Test bench
-- Module Name:    	shiftleftN_tb - Behavioral 
-- Project Name:   	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Shift Left N - Self Checking Test Bench
--					The stimulus process, feeds the uut with a constant value of A
--					and increments the N value (in powers of 2, 2^i, 
--					where i = 0 to 31)
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
 
ENTITY shiftleftN_tb IS
END shiftleftN_tb;
 
ARCHITECTURE behavior OF shiftleftN_tb IS 
	
	constant N : natural :=64;
	
---------------------------------------------------------------------------------
-- Component Declaration for the Unit Under Test (UUT)
---------------------------------------------------------------------------------
 
    COMPONENT shiftleftN
	 generic( width : natural := N );
    PORT(
         SHL_in_A : IN  std_logic_vector(N-1 downto 0);
         SHL_in_N : IN  std_logic_vector(N-1 downto 0);
         SHL_out_RESULT : OUT  std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;
    
---------------------------------------------------------------------------------
-- Temporary signals used for wiring
---------------------------------------------------------------------------------
   --Inputs
   signal SHL_in_A : std_logic_vector(N-1 downto 0) := (others => '0');
   signal SHL_in_N : std_logic_vector(N-1 downto 0) := (others => '0');

 	--Outputs
   signal SHL_out_RESULT : std_logic_vector(N-1 downto 0);
 
BEGIN


---------------------------------------------------------------------------------
-- Instantiating the ShiftLeftN unit
---------------------------------------------------------------------------------
 
	-- Instantiate the Unit Under Test (UUT)
   uut: shiftleftN 
		  generic map(width => N )
		  PORT MAP (
          SHL_in_A => SHL_in_A,
          SHL_in_N => SHL_in_N,
          SHL_out_RESULT => SHL_out_RESULT
        );
 

 ---------------------------------------------------------------------------------
-- Input Stimuli - loop through 32 times, incrementing i, N= 2^i, A = 13
---------------------------------------------------------------------------------

   -- Stimulus process
   stim_proc: process
   begin			
		
		SHL_in_A <= X"0000000000000000";
		SHL_in_N <= X"0000000000000000";
		
		wait for 1000 ns;
		
		
		for i in 0 to 31 loop
			
			-- A fixed at D
			SHL_in_A <= X"000000000000000D";
			
			-- N is incremented every loop cycle
			SHL_in_N <= conv_std_logic_vector(2**i, N);
			
			-- check shift result
			ASSERT SHL_out_RESULT = (SHL_in_A*SHL_in_N)           
			REPORT "i="& integer'image(i)   
			SEVERITY warning;
			
			wait for 10 ns;
			
		end loop;
		
      wait; -- wait indefnitely
		
   end process;

END;