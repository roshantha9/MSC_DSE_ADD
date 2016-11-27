---------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     16:38:54 03/03/2011 
-- Design Name:     Switch Debounce circuit (NEW Design)
-- Module Name:     DebouncerNew - Behavioral 
-- Project Name:    Lab5b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Debounce logic, using 1 sample generator, 1 up counter
--					with overflow and a synchroniser. Design adapter from
--					http://www.labbookpages.co.uk/electronics/debounce.html, 
--					by Dr. Andrew Greensted, accessed 06/04/2011
--
-- Dependencies:    None
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
entity DebouncerNew is
	generic ( 
			  -- sample generator max value
			  SAMPLE_COUNT_MAX 			: natural := 10;
			  
			   -- saturation value
			  PULSE_COUNT_MAX  			: natural := 600000;
			  
			  -- register and counter sizes
			  SAMPLE_GEN_WORD_SIZE 		: natural := 24;
			  DEB_COUNT_WORD_SIZE  		: natural := 24 );
    Port ( 
		   RESET 	: in STD_LOGIC;
		   CLK 	    : in STD_LOGIC;
           Sig 	    : in STD_LOGIC;
           Deb_Sig  : out STD_LOGIC
		 );
end DebouncerNew;

architecture Behavioral of DebouncerNew is

	signal Q0, Q1		: STD_LOGIC;	-- dffs used for synchroniser
	signal sample_now 	: STD_LOGIC;	-- 1 bit register
	-- up counters
	signal sample_count : STD_LOGIC_VECTOR(SAMPLE_GEN_WORD_SIZE-1 downto 0);
	signal deb_count 	: STD_LOGIC_VECTOR(DEB_COUNT_WORD_SIZE-1 downto 0);
	-- reset and enable lines
	signal sat_cnt_rst  : STD_LOGIC;
	signal sat_cnt_en 	: STD_LOGIC;
	
	-- final debounced output
	signal SwitchOut	: STD_LOGIC;
	
begin


----------------------------------------------------------------------
-- SYNCHRONIZER - Minimises Metastability
----------------------------------------------------------------------
-- two flip flops connected to each other
process is
begin
	wait until rising_edge(CLK);
	
	if(RESET = '1') then
		Q0 <= '0';
		Q1 <= '0';	
	else
		Q0 <= Sig;
		Q1 <= Q0;
	end if;			
end process;

----------------------------------------------------------------------
-- SAMPLE PULSE GENERATOR (Wrapping Counter ) 
----------------------------------------------------------------------
	-- sample generator (clock divider)
	-- counts up to a max value. produces a signal 
	-- when max value has been reached
	p_sample_gen: process is
	begin
		wait until rising_edge(CLK);
		-- reset counter
		if (RESET='1') then
			sample_count <= (others =>'0');
			sample_now <= '0';			
		else
			if (sample_count = conv_std_logic_vector(SAMPLE_COUNT_MAX, 
													SAMPLE_GEN_WORD_SIZE)) then
				sample_count <= (others => '0');	-- reset sample_count
				sample_now <= '1';					
			else
				sample_count <= sample_count + 1;
				sample_now <= '0';
			end if;
		end if;
	end process;


----------------------------------------------------------------------
-- DEBOUNCER ( Saturating Counter ) 
----------------------------------------------------------------------
	sat_cnt_rst <= (not Q1) or RESET;
	sat_cnt_en  <= sample_now and Q1;
	--sat_cnt_en  <=  Q1;
	
	p_debounce: process is
	begin
		wait until rising_edge(CLK);
		-- reset counter
		if (sat_cnt_rst='1') then
			deb_count <= (others =>'0');
			SwitchOut <= '0';
		else
			if(sat_cnt_en='1') then -- button pressed and sample event
				if(deb_count = conv_std_logic_vector(PULSE_COUNT_MAX, DEB_COUNT_WORD_SIZE)) then
					deb_count <= (others => '0');	-- reset deb_count
					SwitchOut <= '1';
				else
					deb_count <= deb_count + 1;
					SwitchOut <= '0';
				end if;
			else
				-- reset counter
				deb_count <= (others =>'0');
				SwitchOut <= '0';
			end if;
		end if;			
	end process;
	
Deb_Sig <= SwitchOut;

end Behavioral;

