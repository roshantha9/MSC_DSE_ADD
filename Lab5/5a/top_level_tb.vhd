----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	14:07:58 03/10/2011
-- Design Name: 	top level circuit test bench
-- Module Name:    	top_level_tb.vhd - Behavioural 
-- Project Name:   	Lab5a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Top Level Circuit Test bench of BIST and UUT, 
--					able to inject 3 individual faults.
--
-- Dependencies: 	top_level
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY top_level_tb IS
END top_level_tb;
 
ARCHITECTURE behavior OF top_level_tb IS 

----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
		
	 constant clk_period :time := 5 ns;
----------------------------------------------------------------------------------
-- Component Declaration for the Unit Under Test (UUT) - top_level
----------------------------------------------------------------------------------    
    COMPONENT top_level
    PORT(
         CLK 		: IN  std_logic;
         B_RST 		: IN  std_logic;
         B_TEST 	: IN  std_logic;
         B_FLT 		: IN  std_logic_vector(2 downto 0);
         L_OUT 		: OUT  std_logic;
         L_ERR 		: OUT  std_logic;
         L_ID 		: OUT  std_logic_vector(3 downto 0);	
		 TOP_INPUTS : IN STD_LOGIC_VECTOR(5 downto 0));			
    END COMPONENT;

----------------------------------------------------------------------------------
-- Test Vectors - random inputs to the circuit, using VHDL records
---------------------------------------------------------------------------------- 
	
	-- vhdl record containing the test vectors
	type test_struct is record
		-- intputs
		A_TST : STD_LOGIC;
		B_TST : STD_LOGIC;
		C_TST : STD_LOGIC;
		D_TST : STD_LOGIC;
		E_TST : STD_LOGIC;
		F_TST : STD_LOGIC;	
	end record test_struct;

	type test_sample_array is array (natural range <>)
		of test_struct;
		
	constant test_vectors: test_sample_array :=
	-- some random inputs to the circuit
	-- A, B, C, D, E, F
	(	   			
		('0','0','0','0','0','0'),					-- 0
		('1','1','0','0','0','0'),					-- 1
		('0','0','0','0','0','1'),					-- 2
		('0','0','1','1','0','0'),					-- 3	
		('1','0','0','0','0','0'),					-- 4
		('0','1','0','0','0','0'),					-- 5
		('0','0','1','0','0','0'),					-- 6
		('0','0','0','1','0','0'),					-- 7		
		('0','0','0','0','1','0'),					-- 8		
		('0','0','0','1','1','1'),					-- 9
		('0','1','0','0','0','1'),					-- 10
		('1','1','0','0','0','1'),					-- 11
		('0','0','1','0','0','1'),					-- 12
		('0','0','0','1','0','1'),					-- 13
		('1','1','1','0','0','1'),					-- 14
		('1','1','0','0','0','1'),					-- 15
		('1','0','1','0','0','1'),					-- 16
		('1','0','0','1','0','1'),					-- 17
		('1','0','0','0','1','1'),					-- 18
		('1','1','1','0','0','1')					-- 19
	);    		

----------------------------------------------------------------------------------
-- Temporary Signals used to wire up the UUT
---------------------------------------------------------------------------------- 		
   --Inputs
   signal CLK_TB 		: STD_LOGIC := '0';
   signal B_RST_TB 		: STD_LOGIC := '0';
   signal B_TEST_TB 	: STD_LOGIC := '0';
   signal B_FLT_TB 		: STD_LOGIC_VECTOR(2 downto 0) 	 := (others => '0');
   signal TOP_INPUTS_TB : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');

 	--Outputs
   signal L_OUT_TB 		: STD_LOGIC;
   signal L_ERR_TB 		: STD_LOGIC;
   signal L_ID_TB 		: STD_LOGIC_VECTOR(3 downto 0);
 
BEGIN

----------------------------------------------------------------------------------
-- Instantiate the UUT
----------------------------------------------------------------------------------

	-- Instantiate the Unit Under Test (UUT)
   uut: top_level PORT MAP (
          CLK 			=> CLK_TB,
          B_RST 		=> B_RST_TB,
          B_TEST 		=> B_TEST_TB,
          B_FLT 		=> B_FLT_TB,
          L_OUT 		=> L_OUT_TB,
          L_ERR 		=> L_ERR_TB,
          L_ID 			=> L_ID_TB,
		  TOP_INPUTS 	=> TOP_INPUTS_TB
        );
 
----------------------------------------------------------------------------------
-- Clock Generation process
----------------------------------------------------------------------------------
  
   clk_process :process
   begin
		CLK_TB <= '0';
		wait for clk_period/2;
		CLK_TB <= '1';
		wait for clk_period/2;
   end process;
 
----------------------------------------------------------------------------------
-- Main Stimulus Process - test vectors are fed into the UUT, and when 5 of the 
-- inputs have been entered, the TEST button is made high, and a fault is injected
-- into the system. 
-- The following faults can be injected:
-- F s@1 (001)
-- H s@0 (010)
-- J s@1 (100)
-- no errors (000)
----------------------------------------------------------------------------------
   stim_proc: process
   begin		
   
		-- hold reset state for 100 ns.
		B_RST_TB <= '1';
		wait for (clk_period*20);
		B_RST_TB <= '0';

     for i in test_vectors'range loop
		
			TOP_INPUTS_TB(0) <= test_vectors(i).A_TST;
			TOP_INPUTS_TB(1) <= test_vectors(i).B_TST;
			TOP_INPUTS_TB(2) <= test_vectors(i).C_TST;
			TOP_INPUTS_TB(3) <= test_vectors(i).D_TST;
			TOP_INPUTS_TB(4) <= test_vectors(i).E_TST;
			TOP_INPUTS_TB(5) <= test_vectors(i).F_TST;
						
			-- when half the tests have completed, we inject a fault:
			if (i=5) then
				B_TEST_TB <= '1';
				--B_FLT_TB  <= "000";	-- no errors
				B_FLT_TB  <= "001"; 	-- F s@1
				--B_FLT_TB  <= "010";	-- H s@0
				--B_FLT_TB  <= "100";	-- J s@1			
				
			end if;
			
			wait for clk_period; -- wait for 1 clock period and 
								 -- then start where it left off
		
	  end loop;
	  wait;

   end process;
END;
