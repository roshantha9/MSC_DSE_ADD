---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	21:56:31 02/11/2010 
-- Design Name:   	top_level
-- Module Name:   	top_level - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Top Level Circuit
--
-- Dependencies: 	ADC, DAC, Debouncer, Control
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    Port ( BUTTON 			: in  STD_LOGIC;
           CLK				: in  STD_LOGIC;
           RST 				: in  STD_LOGIC;
           LED 				: out  STD_LOGIC_VECTOR(7 downto 0);
			  
		   -- internal signals being taken out  for debugging --
		   TOP_DATABUS		: out STD_LOGIC_VECTOR(3 downto 0);
			  
		   TOP_ADC_BUSREQ	: out STD_LOGIC;
		   TOP_ADC_BUSGRNT	: out STD_LOGIC;
		   TOP_ADC_DACSEL	: out STD_LOGIC_VECTOR(3 downto 0);			
		   TOP_ADC_COUNTER  : out STD_LOGIC_VECTOR(3 downto 0);
			 
		   TOP_DAC1_BUSREQ	: out STD_LOGIC;
		   TOP_DAC1_GRANT	: out STD_LOGIC;
		   TOP_DAC1_LED		: out STD_LOGIC_VECTOR(3 downto 0);		  
			  
		   TOP_DAC2_BUSREQ	: out STD_LOGIC;
		   TOP_DAC2_GRANT	: out STD_LOGIC;
		   TOP_DAC2_LED		: out STD_LOGIC_VECTOR(3 downto 0));			  
			  
end top_level;

architecture Behavioral of top_level is
	
----------------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------------
	
	-- ADC component definition
	COMPONENT ADC
	PORT(
		CLK : IN std_logic;
		CLK_EN : IN std_logic;
		RST : IN std_logic;
		BUS_GRANTED : IN std_logic;    
		DATA_BUS : INOUT std_logic_vector(3 downto 0);      
		BUS_REQ : OUT std_logic;
		DAC_SEL : OUT std_logic_vector(3 downto 0);
		
		-- taken out for debug purposes --
		ADC_COUNTER: out STD_LOGIC_VECTOR (3 downto 0)
		);
	END COMPONENT;
	
	-- DAC component definition
	COMPONENT DAC
	PORT(
		CLK : IN std_logic;
		CLK_EN : IN std_logic;
		RST : IN std_logic;
		DAC_SEL : IN std_logic_vector(3 downto 0);
		BUS_GRANTED : IN std_logic;
		DAC_ID : IN std_logic_vector(3 downto 0);    
		DATA_BUS : INOUT std_logic_vector(3 downto 0);      
		LED : OUT std_logic_vector(3 downto 0);
		BUS_REQ : OUT std_logic
		);
	END COMPONENT;
	
	-- Control component definition
	COMPONENT Control
	PORT(
		DAC1_REQ : IN std_logic;
		DAC2_REQ : IN std_logic;
		ADC_REQ : IN std_logic;          
		ADC_CTRL : OUT std_logic;
		DAC1_CTRL : OUT std_logic;
		DAC2_CTRL : OUT std_logic
		);
	END COMPONENT;
	
	-- Debouncer component definition
	COMPONENT Debouncer
	PORT(
		CLK : IN std_logic;
		Sig : IN std_logic;          
		Deb_Sig : OUT std_logic
		);
	END COMPONENT;
	
----------------------------------------------------------------------------------
-- TEMPORARY SIGNALS USED FOR WIRING
----------------------------------------------------------------------------------
	
	signal adc_req, dac1_req, dac2_req : STD_LOGIC; -- requests to gain control of the bus
	signal adc_grant, dac1_grant, dac2_grant : STD_LOGIC; -- bus control granted
    signal data_bus : STD_LOGIC_VECTOR(3 downto 0); -- the bidirectional bus
	signal dac_sel : STD_LOGIC_VECTOR(3 downto 0);  -- the id of the active DAC
	signal deb_but, deb_rst : STD_LOGIC; -- debounced versions of the input buttons
	
	signal temp_led	: STD_LOGIC_VECTOR (7 downto 0);
	
	signal adc_counter: STD_LOGIC_VECTOR (3 downto 0);
	
begin
	
	
	LED <= temp_led;
	
----------------------------------------------------------------------------------
-- DEBUGGING: internals signals extended outside for debugging purposes
----------------------------------------------------------------------------------

   TOP_DATABUS			<= data_bus;
  
   TOP_ADC_BUSREQ		<= adc_req;
   TOP_ADC_BUSGRNT		<= adc_grant;
   TOP_ADC_DACSEL		<= dac_sel;
   TOP_ADC_COUNTER   	<= adc_counter;

   TOP_DAC1_BUSREQ		<= dac1_req;
   TOP_DAC1_GRANT	 	<= dac1_grant;
   TOP_DAC1_LED			<= temp_led(3 downto 0);
  
   TOP_DAC2_BUSREQ		<= dac2_req;
   TOP_DAC2_GRANT	 	<= dac2_grant;
   TOP_DAC2_LED			<= temp_led(7 downto 4);
	
	
----------------------------------------------------------------------------------
-- COMPONENT INSTATIATION
----------------------------------------------------------------------------------	
	-- ADC (Source)
	Inst_ADC: ADC PORT MAP(
		CLK => CLK,
		CLK_EN => deb_but,
		RST => deb_rst,
		BUS_GRANTED => adc_grant,
		DATA_BUS => data_bus,
		BUS_REQ => adc_req,
		DAC_SEL => dac_sel,
		
		ADC_COUNTER => adc_counter
	);
	
	-- DAC1 (Target 1)
	Inst_DAC1: DAC PORT MAP(
		CLK => CLK,
		CLK_EN => deb_but,
		RST => deb_rst,
		DATA_BUS => data_bus,
		LED => temp_led(3 downto 0),
		DAC_SEL => dac_sel,
		BUS_REQ => dac1_req,
		BUS_GRANTED => dac1_grant,
		DAC_ID => "0001" -- unique ID for the DAC
	);
	
	-- DAC2 (Target 2)
	Inst_DAC2: DAC PORT MAP(
		CLK => CLK,
		CLK_EN => deb_but,
		RST => deb_rst,
		DATA_BUS => data_bus,
		LED => temp_led(7 downto 4),
		DAC_SEL => dac_sel,
		BUS_REQ => dac2_req,
		BUS_GRANTED => dac2_grant,
		DAC_ID => "0010" -- unique ID for the DAC
	);
	
	-- Control (Data Bus controller)
	Inst_Control: Control PORT MAP(
		DAC1_REQ => dac1_req,
		DAC2_REQ => dac2_req,
		ADC_REQ => adc_req,
		ADC_CTRL => adc_grant,
		DAC1_CTRL => dac1_grant,
		DAC2_CTRL => dac2_grant
	);
	
	-- Debouncer (RST Debouncer)
	Inst_Debouncer_RST: Debouncer PORT MAP(
		CLK => CLK,
		Sig => RST,
		Deb_Sig => deb_rst
	);
	-- Debouncer (BUTTON Debouncer)
	Inst_Debouncer_BUT: Debouncer PORT MAP(
		CLK => CLK,
		Sig => BUTTON,
		Deb_Sig => deb_but
	);

end Behavioral;




