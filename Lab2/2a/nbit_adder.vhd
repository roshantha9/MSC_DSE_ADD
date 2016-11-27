----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	19:53:44 01/27/2011 
-- Design Name: 	n-bit Adder
-- Module Name:    	nbit_adder - Behavioral 
-- Project Name:   	Lab2a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	n-bit Adder implemented using array of Full Adders
--
-- Dependencies: 	fa (full adder module)
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


-- Declaration of entity
entity nbit_adder is
   generic ( width : NATURAL := 32 );	-- input vector width
   port (ADDER_X, ADDER_Y   : in  STD_LOGIC_VECTOR(width-1 downto 0);
         ADDER_CIN  		: in STD_LOGIC;		-- carry in
		 ADDER_SUM  		: out STD_LOGIC_VECTOR(width-1 downto 0);
		 ADDER_COUT 		: out STD_LOGIC );	-- carry out
end nbit_adder;


-- architecture declaration
architecture behavioural of nbit_adder is
  
  -- using the 1 bit full adder
  component fa
    port (FA_in_X, FA_in_Y, FA_in_CIN : in  STD_LOGIC;
		    FA_out_SUM, FA_out_COUT     : out STD_LOGIC);
  end component;

  -- temp signal to calculate cin
  signal temp_cin : STD_LOGIC_VECTOR (width downto 0);
  
  -- begin architecture
  begin

	 -- generating an array of 1bit full adders
	 -- carry out of previous FA connected to the next FA.
    g_fa : for i in 0 to ADDER_SUM'LENGTH-1 generate
      i_fa_1 : entity work.fa(behavioural)
    
      port map( FA_in_X 		=> ADDER_X(i),
                FA_in_Y 		=> ADDER_Y(i),
                FA_out_SUM 	=> ADDER_SUM(i),
                FA_in_CIN 		=> temp_cin(i),
                FA_out_COUT 	=> temp_cin(i+1));          
               
    end generate g_fa; 
               
    temp_cin(0) <= ADDER_CIN;	-- top level CIN connected to first FA
    ADDER_COUT <= temp_cin(width); -- last cout is connected to top level cout
      
  
end behavioural;
