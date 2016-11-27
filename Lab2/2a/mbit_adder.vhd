----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	19:53:44 01/27/2011 
-- Design Name:    	m-bit Adder
-- Module Name:    	mbit_adder - Behavioral 
-- Project Name:   	Lab2a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	m-bit Adder implemented using array of n-bit Adders
--
-- Dependencies: 	nbit_adder
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
entity mbit_adder is
   generic ( n : NATURAL := 8;
		     m : NATURAL := 64	);
   port (mADDER_X, mADDER_Y    : in  STD_LOGIC_VECTOR(m-1 downto 0);
         mADDER_CIN  		   : in STD_LOGIC;
		 mADDER_SUM  		   : out STD_LOGIC_VECTOR(m-1 downto 0);
		 mADDER_COUT 		   : out STD_LOGIC );
end mbit_adder;

architecture behavioural of mbit_adder is
	
	-- temporary signals used for wiring up
	signal temp_madder_cin : STD_LOGIC_VECTOR(m/n downto 0);
	signal temp_madder_sum : STD_LOGIC_VECTOR(m-1 downto 0);

begin

  temp_madder_cin(0) <= mADDER_CIN;   
     
  -- generate an array of nbit_adder modules because 
  -- of the n-bit i/o of nbit_adder, we have to divide by n
  -- The m-bit vector is split into ((m/n)-1) n-bit groups and
  -- connected to n-bit adder units.
  -- an array of nbit adders are generated.
	g_nbit_adder : for i in 0 to (m/n)-1 generate
	  i_nbit_adder_1 : entity work.nbit_adder(behavioural)
		generic map ( width => n )
		port map (ADDER_X      => mADDER_X((((i+1)*n)-1) downto (i*n)),
				  ADDER_Y      => mADDER_Y((((i+1)*n)-1) downto (i*n)),
				  ADDER_CIN    => temp_madder_cin(i),
                  ADDER_SUM    => temp_madder_sum((((i+1)*n)-1) downto (i*n)), 
                  ADDER_COUT   => temp_madder_cin(i+1));
   end generate;
   
   -- last cin is connected to top level cout
   mADDER_COUT <= temp_madder_cin(m/n);	
   
   -- the full sum vector will contain the individual sums 
   -- of the n-bit components
   mADDER_SUM  <= temp_madder_sum;

end behavioural;

