----------------------------------------------------------------------------------
-- Advanced Digital Design Lab 1
-- University of York
-- Department of Electronics
-- York, UK
-- Gianluca Tempesti, Yang Liu (Jerry), Tuze Kuyucu - January 2010


-- Design Name: a counter circuit
-- Module Name:    counter
-- Description: This code creates a counter circuit which counts from 0 to 15
-- Dependencies: none
--
-- Revision: 1.0

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity timer is
    Port ( count : out  STD_LOGIC_VECTOR (3 downto 0);
           clock : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end timer;

architecture Behavioral of timer is
signal data: STD_LOGIC_VECTOR(3 downto 0):="0000";
begin

process(clock, reset)
variable delay: integer:=0;
begin
	if reset='1' then
		data<= (others=>'0');
		delay:=0;
	elsif (clock='1' and clock'event) then
		 if delay>= 100000000 then
			data<=data+1;
			delay:=0;
		else
			delay:= delay+1;
		end if;
	end if;	
end process;

count <= data;
end Behavioral;

