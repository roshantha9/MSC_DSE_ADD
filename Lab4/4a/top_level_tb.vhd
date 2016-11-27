---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	14:37:53 02/11/2011
-- Design Name:   	top_level_tb
-- Module Name:   	top_level_tb - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Top Level Circuit Test Bench. Self checking Test Bench.
--					Control Unit operations and the top level signal corectness
--					is checked.
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
-- CONSTANTS
----------------------------------------------------------------------------------
	constant clk_period 	: time := 100 ns;
	constant btn_period 	: time := 900 ns;
	constant btn_duration 	: time := 1000 ns;

----------------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------------
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_level
    PORT(
         BUTTON 		: IN  std_logic;
         CLK 			: IN  std_logic;
         RST 			: IN  std_logic;
         LED 			: OUT  std_logic_vector(7 downto 0);
			
		 -- internal signals being taken out  for debugging --
		 TOP_DATABUS		: out STD_LOGIC_VECTOR(3 downto 0);
		 
		 -- ADC related outputs
		 TOP_ADC_BUSREQ		: out STD_LOGIC;
		 TOP_ADC_BUSGRNT	: out STD_LOGIC;
		 TOP_ADC_DACSEL		: out STD_LOGIC_VECTOR(3 downto 0);
		 TOP_ADC_COUNTER 	: out STD_LOGIC_VECTOR(3 downto 0);
			
		 -- DAC1 related outputs
		 TOP_DAC1_BUSREQ	: out STD_LOGIC;
		 TOP_DAC1_GRANT		: out STD_LOGIC;
		 TOP_DAC1_LED		: out STD_LOGIC_VECTOR(3 downto 0);	  
		 
		 -- DAC2 related outputs
		 TOP_DAC2_BUSREQ	: out STD_LOGIC;
		 TOP_DAC2_GRANT		: out STD_LOGIC;
		 TOP_DAC2_LED		: out STD_LOGIC_VECTOR(3 downto 0)						
        );
    END COMPONENT;
    
----------------------------------------------------------------------------------
-- TEMPORARY SIGNALS USED FOR WIRING
----------------------------------------------------------------------------------
   --Inputs
   signal BUTTON_TB : std_logic := '0';
   signal CLK_TB : std_logic := '0';
   signal RST_TB : std_logic := '0';

 	--Outputs
   signal LED_TB : std_logic_vector(7 downto 0);
	
	
	-- internal signals being taken out  for debugging --
	signal TOP_DATABUS_TB	 	 : STD_LOGIC_VECTOR(3 downto 0);
  
	signal TOP_ADC_BUSREQ_TB	 : STD_LOGIC;
	signal TOP_ADC_BUSGRNT_TB	 : STD_LOGIC;
	signal TOP_ADC_DACSEL_TB	 : STD_LOGIC_VECTOR(3 downto 0);
	signal TOP_ADC_COUNTER_TB	 : STD_LOGIC_VECTOR(3 downto 0);
  
	signal TOP_DAC1_BUSREQ_TB	 : STD_LOGIC;
	signal TOP_DAC1_GRANT_TB	 : STD_LOGIC;
	signal TOP_DAC1_LED_TB		 : STD_LOGIC_VECTOR(3 downto 0);  
	
	signal TOP_DAC2_BUSREQ_TB	 : STD_LOGIC;
	signal TOP_DAC2_GRANT_TB	 : STD_LOGIC;
	signal TOP_DAC2_LED_TB		 : STD_LOGIC_VECTOR(3 downto 0);			
		
 
BEGIN
 
----------------------------------------------------------------------------------
-- COMPONENT INSTANTIATION
----------------------------------------------------------------------------------
 
 	-- Instantiate the Unit Under Test (UUT)
   uut: top_level PORT MAP (
          BUTTON => BUTTON_TB,
          CLK => CLK_TB,
          RST => RST_TB,
          LED => LED_TB,			 
			 
		  -- extra signals for debug --
		  TOP_DATABUS		=> TOP_DATABUS_TB,
	  
		  TOP_ADC_BUSREQ	=>	TOP_ADC_BUSREQ_TB,
		  TOP_ADC_BUSGRNT	=> TOP_ADC_BUSGRNT_TB,
		  TOP_ADC_DACSEL	=> TOP_ADC_DACSEL_TB,
		  TOP_ADC_COUNTER	=> TOP_ADC_COUNTER_TB,		 
		
		  TOP_DAC1_BUSREQ	=> TOP_DAC1_BUSREQ_TB,
		  TOP_DAC1_GRANT	=> TOP_DAC1_GRANT_TB,
		  TOP_DAC1_LED		=> TOP_DAC1_LED_TB,		  
		
		  TOP_DAC2_BUSREQ	=> TOP_DAC2_BUSREQ_TB,
		  TOP_DAC2_GRANT	=> TOP_DAC2_GRANT_TB,
		  TOP_DAC2_LED		=> TOP_DAC2_LED_TB		 
        );
 
----------------------------------------------------------------------------------
-- CLOCK PROCESS
----------------------------------------------------------------------------------
	-- clock generator
   clk_process :process
   begin
		CLK_TB <= '0';
		wait for clk_period/2;
		CLK_TB <= '1';
		wait for clk_period/2;
   end process;
 
----------------------------------------------------------------------------------
-- INPUT STIMULUS TO THE UUT
----------------------------------------------------------------------------------
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 950 ns
      RST_TB <= '1';
		wait for clk_period*9 ns;	
		RST_TB <= '0';			
		wait for clk_period*10 ns;
		
		-- loop 32 times : essentially produces 32 cycles for BUTTON
		for i in 0 to 32 loop
			BUTTON_TB <= '1';
			wait for btn_duration;
				
			
			-----------------------------------------------------------------
			-- start checking for signal values
			-----------------------------------------------------------------		
			-- print out led values (verify if as expected)
			-- uncomment 'if' statements to ONLY print out values when
			-- adc_bus_req=0
			
			--if(TOP_ADC_BUSREQ_TB='0') then
			
				report "----- DAC1_LED: " & integer'image(to_integer(unsigned(TOP_DAC1_LED_TB)))
					  & ", DAC2_LED: " & integer'image(to_integer(unsigned(TOP_DAC2_LED_TB)))			  
					  & ", ----- ADC_COUNTER: " & integer'image(to_integer(unsigned(TOP_ADC_COUNTER_TB)))
					  & ", ADC_BUSREQ_TB: " & std_logic'image(TOP_ADC_BUSREQ_TB)
					  & ", ADC_DACSEL: " & integer'image(to_integer(unsigned(TOP_ADC_DACSEL_TB)));					
			--end if;
			
			
			-- check if permission is granted correctly by the control unit
			-- permission for dac1
			assert (TOP_DAC1_BUSREQ_TB = TOP_DAC1_GRANT_TB)
			report "DAC1_BUSREQ: " & std_logic'image(TOP_DAC1_BUSREQ_TB) 
				  & ", DAC1_GRANT : " & std_logic'image(TOP_DAC1_GRANT_TB)
			severity failure;
			
			-- permission for dac2
			assert (TOP_DAC2_BUSREQ_TB = TOP_DAC2_GRANT_TB)
			report "DAC2_BUSREQ: " & std_logic'image(TOP_DAC2_BUSREQ_TB) 
				  & ", DAC2_GRANT : " & std_logic'image(TOP_DAC2_GRANT_TB)
			severity failure;
			
			-- permission for adc
			assert (TOP_ADC_BUSREQ_TB = TOP_ADC_BUSGRNT_TB)
			report "ADC_BUSREQ: " & std_logic'image(TOP_ADC_BUSREQ_TB) 
				  & ", ADC_BUSGRNT : " & std_logic'image(TOP_ADC_BUSGRNT_TB)
			severity failure;

			
			BUTTON_TB <= '0';
			wait for btn_period;			
		end loop;
		
		
		wait; -- wait indefnitely
   end process;

END;
