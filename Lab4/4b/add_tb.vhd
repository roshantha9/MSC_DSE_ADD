--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:41:12 02/21/2011
-- Design Name:   
-- Module Name:   C:/hrm506_ADD/Lab4/Lab4b/add_tb.vhd
-- Project Name:  Lab4b
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: add
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
 
ENTITY add_tb IS
END add_tb;
 
ARCHITECTURE behavior OF add_tb IS 
 
	 constant clk_period : time := 10ns; 
	 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT add
    PORT(
			CLK, RST	: in STD_LOGIC;
         ADD_in_A : IN  std_logic_vector(31 downto 0);
         ADD_in_B : IN  std_logic_vector(31 downto 0);
         ADD_out_SUM : OUT  std_logic_vector(31 downto 0);
         ADD_out_COUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_TB		 : STD_LOGIC;
	signal RST_TB		 : STD_LOGIC;
	signal ADD_in_A_TB : std_logic_vector(31 downto 0) := (others => '0');
   signal ADD_in_B_TB : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal ADD_out_SUM_TB : std_logic_vector(31 downto 0);
   signal ADD_out_COUT_TB : std_logic;
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: add PORT MAP (
          CLK => CLK_TB,
			 RST => RST_TB,			 
			 ADD_in_A => ADD_in_A_TB,
          ADD_in_B => ADD_in_B_TB,
          ADD_out_SUM => ADD_out_SUM_TB,
          ADD_out_COUT => ADD_out_COUT_TB
        );
 
	
	
	-- clock generator
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
      -- hold for 100 ns.
		-- insert stimulus here
		RST_TB <= '1';	
		ADD_in_A_TB <= X"00000000";
		ADD_in_B_TB <= X"00000000";
		
      wait for clk_period*50;
		
		RST_TB <= '0';			

		-- insert stimulus here 
		ADD_in_A_TB <= X"0D000000";
		ADD_in_B_TB <= X"0E000000";
		
      wait;
   end process;

END;
