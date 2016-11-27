----------------------------------------------------------------------------------
-- Advanced Digital Design Lab 1
-- University of York
-- Department of Electronics
-- York, UK
-- Gianluca Tempesti, Yang Liu (Jerry), Tuze Kuyucu - January 2010


-- Design Name: synchronous ram
-- Module Name:    ram256x32
-- Description: This code creates a chunk of ram using the FPGA substrate 

-- Dependencies: ram component
--
-- Revision: 1.0

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ram256x32 is
--make it generic so it can be used to simulate any size of ram
	 generic ( bits: INTEGER:=32;
				 wordSize: INTEGER:=8; --in binary
				 words: INTEGER:=256);
--this is a synchronous RAM with dedicated in out busses
    port ( wr_ne : in  STD_LOGIC;
			  chipNenable: in STD_LOGIC;
			  outputNenable: in STD_LOGIC;
			  clock: in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(wordSize-1 downto 0);
           data_in : in  STD_LOGIC_VECTOR (bits-1 downto 0);
			  data_out : out  STD_LOGIC_VECTOR (bits-1 downto 0));
end ram256x32;

architecture ram of ram256x32 is
--define an array type
	type ram_array is ARRAY (0 to words-1) of STD_LOGIC_VECTOR(bits-1 downto 0);
--create the ram	
	signal memory: ram_array:=(others=>(others=>'0'));
begin
	process (clock, wr_ne)
	begin
		if (wr_ne='0' and chipNenable = '0') then
			if(clock'EVENT and clock= '1') then
				memory(CONV_INTEGER(addr)) <=data_in;
			end if;
		end if;
		data_out<=memory(CONV_INTEGER(addr));
	end process;
end ram;

