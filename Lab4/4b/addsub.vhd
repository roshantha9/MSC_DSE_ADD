----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:37 02/17/2011 
-- Design Name: 
-- Module Name:    addsub - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
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

entity addsub is
generic( width : natural := 16 );
port(
		AS_in_A : in STD_LOGIC_VECTOR(width-1 downto 0);
		AS_in_B : in STD_LOGIC_VECTOR(width-1 downto 0);
		AS_in_SEL : in STD_LOGIC;
		
		AS_out_RESULT : out STD_LOGIC_VECTOR(width-1 downto 0);		
		AS_out_OVR	  : out STD_LOGIC
);


end addsub;


architecture behavioral of addsub is

	signal temp_result : STD_LOGIC_VECTOR(width downto 0);
		
begin
	temp_result <= (AS_in_A + AS_in_B) when AS_in_SEL='0' else	-- add
						(AS_in_A - AS_in_B);								-- subtract
	
	
	AS_out_RESULT <= 	temp_result(width-1 downto 0);							
	
	AS_out_OVR <= temp_result(width) when AS_in_SEL='0' else '0';

end behavioral;

