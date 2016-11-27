--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:29:24 02/04/2011
-- Design Name:   
-- Module Name:   C:/hrm506_ADD/Lab2/src/Lab2c/Lab2c/fib_cir_tb2.vhd
-- Project Name:  Lab2c
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fib_toplevel_cir
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
 
ENTITY fib_cir_tb2 IS
END fib_cir_tb2;
 
ARCHITECTURE behavior OF fib_cir_tb2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fib_toplevel_cir
    PORT(
         COUNT : IN  std_logic;
         RESET : IN  std_logic;
         CLOCK : IN  std_logic;
         FIB_OUT : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal COUNT : std_logic := '0';
   signal RESET : std_logic := '0';
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal FIB_OUT : std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fib_toplevel_cir PORT MAP (
          COUNT => COUNT,
          RESET => RESET,
          CLOCK => CLOCK,
          FIB_OUT => FIB_OUT
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
END;
