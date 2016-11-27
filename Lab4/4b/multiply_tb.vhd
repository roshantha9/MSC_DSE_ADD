--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:59:44 02/22/2011
-- Design Name:   
-- Module Name:   C:/hrm506_ADD/Lab4/Lab4b/multiply_tb.vhd
-- Project Name:  Lab4b
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: multiply
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
 
ENTITY multiply_tb IS
END multiply_tb;
 
ARCHITECTURE behavior OF multiply_tb IS 
	
	 constant clk_period :time := 10 ns;
	 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT multiply
	 generic( width : natural := 32);
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         MUL_in_A : IN  std_logic_vector(31 downto 0);
         MUL_in_B : IN  std_logic_vector(31 downto 0);
         MUL_out_RESULT : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_TB : std_logic := '0';
   signal RST_TB : std_logic := '0';
   signal MUL_in_A_TB : std_logic_vector(31 downto 0) := (others => '0');
   signal MUL_in_B_TB : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal MUL_out_RESULT_TB : std_logic_vector(63 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: multiply 
		generic map( width => 32)
		PORT MAP (
          CLK => CLK_TB,
          RST => RST_TB,
          MUL_in_A => MUL_in_A_TB,
          MUL_in_B => MUL_in_B_TB,
          MUL_out_RESULT => MUL_out_RESULT_TB
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
   clk_process :process
   begin
		CLK_TB <= '0';
		wait for clk_period/2;
		CLK_TB <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		RST_TB <= '1';
      wait for 100 ns;	
		RST_TB <= '0';
		
      wait for clk_period*10;

      -- insert stimulus here 
		MUL_in_A_TB <= X"000000FF";
		MUL_in_B_TB <= X"00000400";

      wait;
   end process;

END;
