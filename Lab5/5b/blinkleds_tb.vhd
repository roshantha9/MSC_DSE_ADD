----------------------------------------------------------------------------------
-- Company: UoY - Electronics
-- Engineer: hrm506
-- 
-- Create Date:    12:43:18 01/28/2011 
-- Design Name: 	 Fibonacci Read From RAM - Test Bench
-- Module Name:    blinkleds_tb - Behavioral 
-- Project Name: Lab2b
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: RAM16X4S
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


-- Declaration of entity blinkleds_tb

entity blinkleds_tb is
end;

-- Implementation of entity blinkleds_tb
architecture behavioural of blinkleds_tb is

constant clk_period 	: time := 10 ns;

component blinkleds
	port(	CLK, RESET : in STD_LOGIC;			-- clock, reset
			BTN_COUNT  : in STD_LOGIC;			-- count enable
			LED 	   : out STD_LOGIC_VECTOR(7 downto 0) -- led output
		);	
end component;



signal BTN_COUNT_TB	: STD_LOGIC := '0';
signal RESET_TB	 	: STD_LOGIC := '0';
signal CLK_TB 	 	: STD_LOGIC := '0';
signal LED_TB	 	: STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');

-- Defining local signals for all IO of the circuit under test
-- Actual implementation of testbench starts here
begin

-- Creating an instance of the blinkleds module
ins_blinkleds: blinkleds
port map(	CLK 		=> CLK_TB,
			RESET 		=> RESET_TB,
			BTN_COUNT 	=> BTN_COUNT_TB,
			LED 	    => LED_TB
		);

-- clock signal
sys_clk: process
	begin
		wait for clk_period;
		CLK_TB <= not CLK_TB;	
	end process sys_clk;
				
-- simulating a bouncy signal
-- 5ns bounciness at edges
proc_bouncy_input: process
	begin
		
		wait for clk_period*10;
		BTN_COUNT_TB <= '1';
		wait for clk_period;
		BTN_COUNT_TB <= '0';
		wait for clk_period;
		BTN_COUNT_TB <= '1';
		wait for clk_period;
		BTN_COUNT_TB <= '0';
		wait for clk_period;
		BTN_COUNT_TB <= '1';
		wait for clk_period*50;
		BTN_COUNT_TB <= '0';
		wait for clk_period;
		BTN_COUNT_TB <= '1';
		wait for clk_period;
		BTN_COUNT_TB <= '0';
		wait for clk_period;
		BTN_COUNT_TB <= '1';
		wait for clk_period;
		BTN_COUNT_TB <= '0';	
		
	end process proc_bouncy_input;


-- In the process testcycle, a suitable set of test vectors need to
-- be generated at the inputs of the entity under test.
testcycle: process
   begin
      
		-- reset everything
		--COUNT_TB <= '0';
		RESET_TB <= '1';
		wait for clk_period*5;
		
		-- start testing count button presses
		RESET_TB <= '0';
		wait; -- wait indefinitely		
		
   end process testcycle;
end behavioural;


