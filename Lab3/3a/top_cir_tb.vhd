----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     03:05:36 02/07/2011
-- Design Name:     Top Level Circuit Test Bench
-- Module Name:     top_cir_tb - Behavioral 
-- Project Name:    Lab3a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Top Level circuit test bench. Inputs a bouncy CALC signal
--					periodically
--
-- Dependencies:    mat_mul, mat_mul_controller, debounce
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
 
ENTITY top_cir_tb IS
END top_cir_tb;
 
ARCHITECTURE behavior OF top_cir_tb IS 

----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
	constant clk_period 			: time := 10ns;	
	constant m_tb 					: natural := 3;
	constant x_tb 					: natural := 4;
	constant y_tb 					: natural := 5;				 
	constant ram_addr_size_tb 		: natural := 4;
	constant ram_data_width_tb 		: natural := 8;
	constant macc_data_size_a_tb 	: natural := 18;
	constant macc_data_size_b_tb 	: natural := 18;
	constant macc_data_size_c_tb 	: natural := 48;
	constant macc_data_size_p_tb 	: natural := 48;
	constant result_width_tb 		: natural := 7;
	constant ram_c_addr_size_tb 	: natural := 5;
	constant ram_c_data_width_tb 	: natural := 48;


----------------------------------------------------------------------------------
-- Component Declaration (top_cir)
----------------------------------------------------------------------------------
    
    component top_cir
	 -- circuit generics, params
		generic ( 
					 -- matrix sizes
					 m 					: natural := m_tb;	
					 x 					: natural := x_tb;
					 y 					: natural := y_tb;
					 -- ram size
					 ram_addr_size 		: natural := ram_addr_size_tb;
					 ram_data_width 	: natural := ram_data_width_tb;
					 ram_c_addr_size 	: natural := ram_c_addr_size_tb;
					 ram_c_data_width 	: natural := ram_c_data_width_tb
					 -- macc unit size
					 macc_data_size_a 	: natural := macc_data_size_a_tb;
					 macc_data_size_b 	: natural := macc_data_size_b_tb;
					 macc_data_size_c 	: natural := macc_data_size_c_tb;
					 macc_data_size_p 	: natural := macc_data_size_p_tb;
					 -- result bus size (truncated)
					 result_width 		: natural := result_width_tb;					 
				  );
		port (
				CLK 				: in STD_LOGIC;
				
				-- button presses --
				BTN_RESET 			: in STD_LOGIC;
				BTN_CALC  			: in STD_LOGIC;
				
				-- outputs --
				OUT_PRD_COEF_TRUNC 	: out STD_LOGIC_VECTOR(result_width-1 downto 0);
				OUT_CALC_COMPLETE 	: out STD_LOGIC	
		);
	end component;	 

----------------------------------------------------------------------------------
-- Temporary signals used for wiring
----------------------------------------------------------------------------------	
   -- external Inputs
   signal CLK_TB 				: std_logic := '0';
   signal BTN_RESET_TB  		: std_logic := '0';
   signal BTN_CALC_TB  			: STD_LOGIC := '0';
   
 	--data path Outputs
   signal OUT_PRD_COEF_TRUNC_TB : STD_LOGIC_VECTOR(result_width_tb-1 downto 0);
   signal OUT_CALC_COMPLETE_TB  : STD_LOGIC;	
	
	
	
BEGIN
 
----------------------------------------------------------------------------------
-- Component Instantiation (UUT)
----------------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
   uut: top_cir
	generic map( 	
					 -- matrix sizes
					 m 					=> m_tb,
					 x 					=> x_tb,
					 y 					=> y_tb,
					 -- ram sizes
					 ram_addr_size 		=> ram_addr_size_tb,
					 ram_data_width 	=> ram_data_width_tb,
					 ram_c_addr_size 	=> ram_c_addr_size_tb,
					 ram_c_data_width 	=> ram_c_data_width_tb
					 -- macc unit size
					 macc_data_size_a 	=> macc_data_size_a_tb,
					 macc_data_size_b 	=> macc_data_size_b_tb,
					 macc_data_size_c 	=> macc_data_size_c_tb,
					 macc_data_size_p 	=> macc_data_size_p_tb,
					 -- truncated result bus size
					 result_width 		=> result_width_tb,					 
				  )
		port map(
					CLK => CLK_TB,
				
					-- button presses --
					BTN_RESET  			=> BTN_RESET_TB,
					BTN_CALC  			=> BTN_CALC_TB,
					
					-- outputs --
					OUT_PRD_COEF_TRUNC 	=> OUT_PRD_COEF_TRUNC_TB,
					OUT_CALC_COMPLETE 	=> OUT_CALC_COMPLETE_TB
				);
	
----------------------------------------------------------------------------------
-- Clock Process (clock generation)
----------------------------------------------------------------------------------	
 
	clk_process :process
   begin
		CLK_TB <= '0';
		wait for clk_period/2;
		CLK_TB <= '1';
		wait for clk_period/2;
   end process;

----------------------------------------------------------------------------------
-- Process block : to handle reset signal
----------------------------------------------------------------------------------	   

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ns.
		BTN_RESET_TB <= '1';
		wait for clk_period*10;
		BTN_RESET_TB <= '0';		     
      wait;
   end process;
----------------------------------------------------------------------------------
-- Process block : to handle bouncy signal input
----------------------------------------------------------------------------------		
	-- simulating a bouncy input signal - user button press
	proc_bouncy_input: process
	begin
		
		-- bouncyness on the edges (falling and rising)
		wait for clk_period*30;
		BTN_CALC_TB <= '1';
		wait for clk_period/2;
		BTN_CALC_TB <= '0';
		wait for clk_period/2;
		BTN_CALC_TB <= '1';
		wait for clk_period/2;
		BTN_CALC_TB <= '0';
		wait for clk_period/2;
		BTN_CALC_TB <= '1';
		wait for clk_period*5;
		BTN_CALC_TB <= '0';
		wait for clk_period/2;
		BTN_CALC_TB <= '1';
		wait for clk_period/2;
		BTN_CALC_TB <= '0';
		wait for clk_period/2;
		BTN_CALC_TB <= '1';
		wait for clk_period/2;
		BTN_CALC_TB <= '0';
		
	end process proc_bouncy_input;
	
	
END;
