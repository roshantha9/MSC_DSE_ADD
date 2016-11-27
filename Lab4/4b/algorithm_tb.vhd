--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:20:41 03/07/2011
-- Design Name:   
-- Module Name:   D:/ADD/Lab4/Lab4b/Lab4b/algorithm_tb.vhd
-- Project Name:  Lab4b
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: algorithm_piped
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
use ieee.std_logic_arith.ALL;
 
ENTITY algorithm_tb IS
END algorithm_tb;
 
ARCHITECTURE behavior OF algorithm_tb IS

	constant clk_period : time := 5 ns;	-- in ns
	constant pipe_stages : natural := 5;
 
	--------------------------------------------------------
	-- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT algorithm
    PORT(
         
		 A : IN  std_logic_vector(15 downto 0);
         B : IN  std_logic_vector(15 downto 0);
         C : IN  std_logic_vector(15 downto 0);
         D : IN  std_logic_vector(31 downto 0);
         CLK : IN  std_logic;
         overflow : OUT  std_logic;
         O : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    --------------------------------------------------------

	-- vhdl record containing the test vectors
	type algorithm_io is record
		-- intputs
		A_TB : integer;
		B_TB : integer;
		C_TB : integer;
		D_TB : integer;
		
		-- outputs
		O_TB : integer;
	end record algorithm_io;

	type test_sample_array is array (natural range <>)
		of algorithm_io;
	constant test_vectors: test_sample_array :=
	-- A, B, C, D, O
	(	   	
		
		(5,2,3,4,29),					-- 0
		(6,3,4,8,101),					-- 1
		(7,4,5,16,325),					-- 2
		(8,5,6,32,965),					-- 3
		(9,6,7,64,2693),				-- 4		
		(10,7,8,128,7173),				-- 5
		(11,8,9,256,18437),				-- 6
		(12,9,10,512,46085),			-- 7
		(13,10,11,1024,112645),			-- 8
		(14,11,12,2048,270341)			-- 9

	);    
	
	
   --Inputs
   signal A : std_logic_vector(15 downto 0) := (others => '0');
   signal B : std_logic_vector(15 downto 0) := (others => '0');
   signal C : std_logic_vector(15 downto 0) := (others => '0');
   signal D : std_logic_vector(31 downto 0) := (others => '0');
   signal CLK : std_logic := '0';

 	--Outputs
   signal overflow : std_logic;
   signal O : std_logic_vector(63 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: algorithm PORT MAP (
          A => A,
          B => B,
          C => C,
          D => D,
          CLK => CLK,
          overflow => overflow,
          O => O
        );
 
   -- No clocks detected in port list. Replace CLK below with 
   -- appropriate port name 
 
   
   clk_process :process
   begin
		CLK <= '0';
		wait for (clk_period/2);
		CLK <= '1';
		wait for (clk_period/2);
   end process;
	
	-- proc_check : process
	-- begin 
		
		--hold reset state for 100ms.		
		-- wait for (clk_period*100);
		-- wait for ((clk_period*pipe_stages)+clk_period/1.5);
		
		
		-- for i in test_vectors'range loop
		
			-- assert (O = conv_std_logic_vector(test_vectors(i).O_TB, 64))
			-- report "FAIL!:Test Vector " & integer'image(i) & "failed! for input "&
					-- "A=" & integer'image(test_vectors(i).A_TB)&", "&
					-- "B="&integer'image(test_vectors(i).B_TB)&", "&
					-- "C="&integer'image(test_vectors(i).C_TB)&", "&
					-- "D="&integer'image(test_vectors(i).D_TB)
					-- severity warning;
			
			-- wait for clk_period;
		
		-- end loop;
		
		-- wait;
		
	-- end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state 
	  --RST <= '1';
      wait for clk_period*100;	
	  --RST <= '0';
		
	  for i in 	test_vectors'range loop
		
		A <= conv_std_logic_vector(test_vectors(i).A_TB, 16);
		B <= conv_std_logic_vector(test_vectors(i).B_TB, 16);
		C <= conv_std_logic_vector(test_vectors(i).C_TB, 16);
		D <= conv_std_logic_vector(test_vectors(i).D_TB, 32);
		
		wait for clk_period;
		
	  end loop;
	  wait;
		
   end process;
END;
