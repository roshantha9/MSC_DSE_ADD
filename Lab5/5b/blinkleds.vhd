----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     13:57:19 03/28/2011 
-- Design Name:     BlinkLEDs
-- Module Name:     blinkleds - Behavioral
-- Project Name:    Lab5b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     The test circuit for the new debouncer. 8 LEDs will represent
--					a 8-bit binary value, whichi is incremented every time the user
--					presses the push button. The push button is connected to a
--					debouncer - and the debouncer output is connected to a
--					8bit counters, clock enable. The counter output COUNT, is then
--					connected to the LEDs.
--
-- Dependencies:    DebouncerNew, debug, scope
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

----------------------------------------------------------------------------------
-- Entity Declaration
----------------------------------------------------------------------------------

entity blinkleds is
	port(	CLK, RESET : in STD_LOGIC;			-- clock, reset
			BTN_COUNT  : in STD_LOGIC;			-- count enable
			LED 	   : out STD_LOGIC_VECTOR(7 downto 0) -- led output
		);			

end blinkleds;

architecture Behavioral of blinkleds is

----------------------------------------------------------------------------------
-- Constants : Debounce Related
----------------------------------------------------------------------------------
	-- debounce specific constants
	constant  DB_SAMPLE_COUNT_MAX 		: natural := 0;
	constant  DB_PULSE_COUNT_MAX  		: natural := 9000000;
	constant  DB_SAMPLE_GEN_WORD_SIZE 	: natural := 4;
	constant  DB_DEB_COUNT_WORD_SIZE  	: natural := 32; 
		
----------------------------------------------------------------------------------
-- Component Declaration : DebounceNew
----------------------------------------------------------------------------------	
	COMPONENT DebouncerNew
		generic ( 
				  -- sample generator max value
				  SAMPLE_COUNT_MAX : natural := DB_SAMPLE_COUNT_MAX;
				  
				  -- saturation value
				  PULSE_COUNT_MAX  : natural := DB_PULSE_COUNT_MAX;
				  
				  -- register and counter sizes
				  SAMPLE_GEN_WORD_SIZE : natural := DB_SAMPLE_GEN_WORD_SIZE;
				  DEB_COUNT_WORD_SIZE  : natural := DB_DEB_COUNT_WORD_SIZE );
		Port ( 
			   RESET 	: in STD_LOGIC;
			   CLK 	    : in STD_LOGIC;
			   Sig 	    : in STD_LOGIC;
			   Deb_Sig  : out STD_LOGIC);
	END COMPONENT;
----------------------------------------------------------------------------------
-- Component Declaration : ChipScope ILA, debug
----------------------------------------------------------------------------------				
	COMPONENT debug
	  port (
		CLK 	: in STD_LOGIC; 
		CONTROL : inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
		TRIG0 	: in STD_LOGIC_VECTOR ( 0 downto 0 ); 
		DATA	: in STD_LOGIC_VECTOR ( 15 downto 0 ) 
	  );
	END COMPONENT;

----------------------------------------------------------------------------------
-- Component Declaration : ChipScope ICON, scope
----------------------------------------------------------------------------------		
	COMPONENT scope
	  port (
		CONTROL0 : inout STD_LOGIC_VECTOR ( 35 downto 0 ) 
	  );
	END COMPONENT;	
			
			
	signal count 	 		: STD_LOGIC_VECTOR(7 downto 0);
	signal deb_count 		: STD_LOGIC;
	
	-- chipscope related
	signal icon_control0 	: STD_LOGIC_VECTOR(35 downto 0);
	signal debug_data    	: STD_LOGIC_VECTOR(15 downto 0);
	signal debug_trigger 	: STD_LOGIC_VECTOR(0 downto 0);

begin
----------------------------------------------------------------------------------
-- Component Instantiation: DebouncerNew
----------------------------------------------------------------------------------	
	-- debounce instantiation
	Inst_Debouncer_BTN_COUNT: DebouncerNew
		generic map ( 
			   -- sample generator max value
			   SAMPLE_COUNT_MAX 	=> DB_SAMPLE_COUNT_MAX,
				  
			   -- saturation value
			   PULSE_COUNT_MAX  	=> DB_PULSE_COUNT_MAX,
				  
			   -- register and counter sizes
			   SAMPLE_GEN_WORD_SIZE => DB_SAMPLE_GEN_WORD_SIZE,
			   DEB_COUNT_WORD_SIZE  => DB_DEB_COUNT_WORD_SIZE )
		port map( 
			   RESET 				=> RESET,
			   CLK 	    			=> CLK,
			   Sig 	    			=> BTN_COUNT,
			   Deb_Sig  			=> deb_count);

----------------------------------------------------------------------------------
-- Counter Process: Increments a 8 bit counter, connected to the LEDs
----------------------------------------------------------------------------------			   
	-- counter behaviour
	-- with synchronous reset, and clock enable
	p_counter: process(CLK)
	begin
	
	 if CLK='1' and CLK'event then
		  if RESET='1' then 
			 count <= (others => '0');
		  elsif deb_count='1' then	-- if count enable is true then count up
			 count<= count + 1;
		  end if;
	 end if;
	
	end process;

	LED <= count;
	
----------------------------------------------------------------------------------
-- Adding ChipScope ICON + ILA to debug Debouncer
----------------------------------------------------------------------------------
	
	debug_data(15 downto 12) <= (others => '0');	-- blank, for future use
	debug_data(11 downto 4) <= count;				-- led counter output
	debug_data(3) <= CLK;
	debug_data(2) <= RESET;
	debug_data(1) <= BTN_COUNT;						-- button raw input
	debug_data(0) <= deb_count;						-- cleaned, debouncer output
		
	debug_trigger(0) <= BTN_COUNT;					-- trigger : button raw input
	
----------------------------------------------------------------------------------
-- Component Instantiation: debug
----------------------------------------------------------------------------------	
	-- ILA module
	i_debug: debug
	  port map (
		CLK 	=> CLK,
		CONTROL => icon_control0,
		TRIG0 	=> debug_trigger,
		DATA	=> debug_data
	  );
	  
----------------------------------------------------------------------------------
-- Component Instantiation: scope
----------------------------------------------------------------------------------	
	-- ICON module 
	i_scope: scope
	  port map(
		CONTROL0 => icon_control0
	  );
	

end Behavioral;

