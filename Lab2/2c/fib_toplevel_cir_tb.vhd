----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     13:49:29 01/31/2011 
-- Design Name:     Fibonacci Top Level Circuit - Test bench
-- Module Name:     fib_toplevel_cir_tb - Behavioral 
-- Project Name:    Lab2c
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Produces a bouncy signal, which is fed into the top level
--					circuit continously, in a process
--
-- Dependencies:    fib_toplevel_cir
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

-- VHDL libraries for standard logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Declaration of entity fib_toplevel_cir_tb

entity fib_toplevel_cir_tb is
end;

-- Implementation of entity fib_toplevel_cir_tb
architecture behavioural of fib_toplevel_cir_tb is


	constant tb_fib_width   : natural := 8;
	constant tb_ram_width 	: natural := 4;
	constant clk_period 	: time := 10 ns;
	

	COMPONENT fib_toplevel_cir
		 GENERIC(  fib_width : NATURAL := tb_fib_width;
				   ram_width : NATURAL := tb_ram_width
				);
		 PORT(
				COUNT : IN  std_logic;
				RESET : IN  std_logic;
				CLOCK : IN  std_logic;
				FIB_OUT : OUT  std_logic_vector(7 downto 0)			
			);
    END COMPONENT;

signal COUNT_TB	 	 : STD_LOGIC := '0';
signal RESET_TB	 	 : STD_LOGIC := '0';
signal CLOCK_TB 	 	 : STD_LOGIC := '0';
signal FIB_OUT_TB     : STD_LOGIC_VECTOR(tb_fib_width-1 downto 0) := (others => '0'); 

-- Defining local signals for all IO of the circuit under test
-- Actual implementation of testbench starts here
begin

-- Creating an instance of the fib_control module
uut: fib_toplevel_cir
     generic map( fib_width => tb_fib_width,
				  ram_width => tb_ram_width
				)
	  port map( COUNT	   => COUNT_TB,
				RESET	   => RESET_TB,
				CLOCK	   => CLOCK_TB,
				FIB_OUT    => FIB_OUT_TB			
			  );

-- clock signal
sys_clk: process
	begin
		wait for clk_period/2;
		CLOCK_TB <= not CLOCK_TB;	
	end process sys_clk;

-- simulating a bouncy input signal - user button press
proc_bouncy_input: process
	begin
		
		wait for clk_period*30;
		COUNT_TB <= '1';
		wait for clk_period/2;
		COUNT_TB <= '0';
		wait for clk_period/2;
		COUNT_TB <= '1';
		wait for clk_period/2;
		COUNT_TB <= '0';
		wait for clk_period/2;
		COUNT_TB <= '1';
		wait for clk_period*50;
		COUNT_TB <= '0';
		wait for clk_period/2;
		COUNT_TB <= '1';
		wait for clk_period/2;
		COUNT_TB <= '0';
		wait for clk_period/2;
		COUNT_TB <= '1';
		wait for clk_period/2;
		COUNT_TB <= '0';	
		
	end process proc_bouncy_input;

	
-- In the process testcycle, a suitable set of test vectors need to
-- be generated at the inputs of the entity under test.
testcycle: process
   begin
      
		-- reset everything
		RESET_TB <= '1';
		wait for clk_period*2;
		
		-- wait indefinitely
		RESET_TB <= '0';	
		wait; 
		
   end process testcycle;
end behavioural;


