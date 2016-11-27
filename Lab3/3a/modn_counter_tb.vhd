----------------------------------------------------------------------------------
-- Company: 			UoY-Elec
-- Engineer: 			106033467
-- 
-- Create Date:    		18:36:20 02/03/2011 
-- Design Name: 	 	mod-n up counter test bench
-- Module Name:    		modn_counter_tb - Behavioral 
-- Project Name:   		Lab3a
-- Target Devices: 		XUPV5-LX110T - Virtex 5
-- Tool versions: 		ISE 10.1
-- Description: Simple Test bench for the mod-n counter unit. 
--
-- Dependencies: None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY modn_counter_tb IS
END modn_counter_tb;

ARCHITECTURE behavior OF modn_counter_tb IS 

----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
 constant nn : NATURAL := 5;
 constant bw : NATURAL := 3;
 constant clk_period : time := 10 ns;

----------------------------------------------------------------------------------
-- Component Declaration
----------------------------------------------------------------------------------
 COMPONENT modn_counter
	generic( n : NATURAL :=nn;
			 bit_width : NATURAL := bw
			 );
	port(	CLK, RESET : in STD_LOGIC;
			EN 		  : in STD_LOGIC;			-- count enable
			COUNT 	  : out STD_LOGIC_VECTOR(bw-1 downto 0); -- current register value
			MAX_FLAG   : out STD_LOGIC	-- max val reached flag
			
		);			
 END COMPONENT;
 
----------------------------------------------------------------------------------
-- Temporary signals used for wiring up
----------------------------------------------------------------------------------
 signal CLK_TB 		: std_logic := '0';
 signal RESET_TB  	: std_logic := '0';
 signal EN_TB 		: std_logic := '0';
 signal COUNT_TB  	: std_logic_vector(bw-1 downto 0);
 signal MAX_FLAG_TB : std_logic;
 signal MAXVAL_TB	: STD_LOGIC_VECTOR(bw-1 downto 0);

BEGIN
		 
----------------------------------------------------------------------------------
-- modn_counter component instantiation (unit under test)
----------------------------------------------------------------------------------	  
 uut: modn_counter 
 generic map( n 		=> nn,
			  bit_width => bw
			)
	port map(	CLK 	 => CLK_TB,
				RESET 	 => RESET_TB,
				EN 		 => EN_TB,
				COUNT 	 => COUNT_TB,
				MAX_FLAG => MAX_FLAG_TB			
			);

----------------------------------------------------------------------------------
-- clock signal
----------------------------------------------------------------------------------	 
 sys_clk: process
 begin
	 wait for clk_period;
	 CLK_TB <= not CLK_TB;	
 end process sys_clk;

----------------------------------------------------------------------------------
--  stimulus inputs are given here
----------------------------------------------------------------------------------	
tb_p1 : process
begin
	
	RESET_TB <= '1';
	EN_TB 	 <= '0';
	wait for clk_period*10;	
	RESET_TB <= '0';
	
	wait for clk_period*20;
	EN_TB 	 <= '1';		
  wait; -- will wait forever    
	
 end process tb_p1;


END;
