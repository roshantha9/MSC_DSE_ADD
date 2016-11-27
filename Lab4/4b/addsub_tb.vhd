--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:54:04 02/17/2011
-- Design Name:   
-- Module Name:   C:/hrm506_ADD/Lab4/Lab4b/addsub_tb.vhd
-- Project Name:  Lab4b
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: addsub
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY addsub_tb IS
END addsub_tb;
 
ARCHITECTURE behavior OF addsub_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT addsub
    PORT(
         AS_in_A : IN  std_logic_vector(15 downto 0);
         AS_in_B : IN  std_logic_vector(15 downto 0);
         AS_in_SEL : IN  std_logic;
         AS_out_RESULT : OUT  std_logic_vector(15 downto 0);
         AS_out_OVR : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal AS_in_A : std_logic_vector(15 downto 0) := (others => '0');
   signal AS_in_B : std_logic_vector(15 downto 0) := (others => '0');
   signal AS_in_SEL : std_logic := '0';

 	--Outputs
   signal AS_out_RESULT : std_logic_vector(15 downto 0);
   signal AS_out_OVR : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: addsub PORT MAP (
          AS_in_A => AS_in_A,
          AS_in_B => AS_in_B,
          AS_in_SEL => AS_in_SEL,
          AS_out_RESULT => AS_out_RESULT,
          AS_out_OVR => AS_out_OVR
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      
		AS_in_A <= X"0000";
		AS_in_B <= X"0000";
		AS_in_SEL <= '0';
		
		wait for 1000 ns;

      -- insert stimulus here 
		AS_in_A <= X"0D00";
		AS_in_B <= X"0E00";

      wait;
   end process;

END;
