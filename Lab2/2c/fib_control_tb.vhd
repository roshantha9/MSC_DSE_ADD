----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     13:49:29 01/31/2011 
-- Design Name:     Fibonacci Controller - Test bench
-- Module Name:     fib_control_tb - Behavioral 
-- Project Name:    Lab2c
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     A bounce COUNT intput is given to the fib_control
--
-- Dependencies:    fib_control
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


-- Declaration of entity fib_control_tb
entity fib_control_tb is
end;

-- Implementation of entity fib_control_tb
architecture behavioural of fib_control_tb is

constant tb_ram_addr_size   : natural := 4;
constant clk_period			: time	  := 10 ns; 

signal COUNT_TB	 	 	: STD_LOGIC := '0';
signal RESET_TB	 	 	: STD_LOGIC := '0';
signal CLOCK_TB 	    : STD_LOGIC := '0';
signal PR_STATE_TB	 	: STD_LOGIC_VECTOR(2 downto 0) := (others=>'0');
signal RAM_WR_EN_TB	 	: STD_LOGIC := '0';
signal RAM_RD_ADDR_TB 	: STD_LOGIC_VECTOR(tb_ram_addr_size-1 downto 0) := (others=>'0');
signal RAM_WR_ADDR_TB 	: STD_LOGIC_VECTOR(tb_ram_addr_size-1 downto 0) := (others=>'0');

signal tmp_deb_count  	: STD_LOGIC := '0';
signal tmp_deb_reset  	: STD_LOGIC := '0';

-- Defining local signals for all IO of the circuit under test
-- Actual implementation of testbench starts here
begin

-- Creating an instance of the fib_control module
i_fib_control1: entity work.fib_control(behavioral)
     generic map( ram_adr_size => tb_ram_addr_size )
	  port map(	
			-- inputs --
			CLOCK 	=>	CLOCK_TB,
			COUNT_IN => tmp_deb_count,
			RESET 	=> RESET_TB,
			MAX_FIB_REACHED => '0',	-- for this simulation we set the 
									-- max_reached to zero throughout
									-- to observe s0-s5 transitions
									
			-- outputs --
			PR_STATE 	=>	PR_STATE_TB,	-- present state of the fsm
			RAM_WR_EN 	=>	RAM_WR_EN_TB,	-- ram write enable signal
			RAM_RD_ADDR =>	RAM_RD_ADDR_TB,	-- ram read address
			RAM_WR_ADDR =>	RAM_WR_ADDR_TB	-- ram read address					
	);	
	
	
	--	-- initialising the debounce module for the COUNT user input
	i_debounce_count: entity work.debounce(behavioral)
	port map( D_IN  => COUNT_TB,
				 CLOCK => CLOCK_TB,
				 RESET => RESET_TB,
				 Q_OUT => tmp_deb_count );
				 
--	-- initialising the debounce module for the RESET user input
--	i_debounce_reset: entity work.debounce(behavioral)
--	port map( D_IN  => RESET_TB,
--				 CLOCK => CLOCK_TB,
--				 RESET => RESET_TB,
--				 Q_OUT => tmp_deb_reset );



-- clock signal
sys_clk: process
	begin
		wait for clk_period;
		CLOCK_TB <= not CLOCK_TB;	
	end process sys_clk;

-- simulating a bouncy input signal - user button press
proc_bouncy_input: process
	begin
		
		wait for clk_period*20;
		COUNT_TB <= '1';
		wait for clk_period;
		COUNT_TB <= '0';
		wait for clk_period;
		COUNT_TB <= '1';
		wait for clk_period*2;
		COUNT_TB <= '0';
		wait for clk_period;
		COUNT_TB <= '1';
		wait for clk_period*100;
		COUNT_TB <= '0';
		wait for clk_period;
		COUNT_TB <= '1';
		wait for clk_period*2;
		COUNT_TB <= '0';
		wait for clk_period;
		COUNT_TB <= '1';
		wait for clk_period;
		COUNT_TB <= '0';	
		
	end process proc_bouncy_input;

-- In the process testcycle, a suitable set of test vectors need to
-- be generated at the inputs of the entity under test.
testcycle: process
   begin
      
		-- reset everything		
		RESET_TB <= '1';
		wait for clk_period*4;
		
		-- start testing reset is off
		RESET_TB <= '0';		
		wait; -- wait indefinitely
		
   end process testcycle;
end behavioural;


