----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:50:48 02/22/2011 
-- Design Name: 
-- Module Name:    multiply - Behavioral 
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

entity multiply is
		generic( width : natural := 8);
		port ( CLK, RST			: in STD_LOGIC;
				 MUL_in_A			: in STD_LOGIC_VECTOR(width-1 downto 0);
				 MUL_in_B			: in STD_LOGIC_VECTOR(width-1 downto 0);
				 MUL_out_RESULT	: out STD_LOGIC_VECTOR((width*2)-1 downto 0)			
		);
end multiply;

architecture Behavioral of multiply is


	signal regA			: STD_LOGIC_VECTOR(width-1 downto 0);
	signal regB			: STD_LOGIC_VECTOR(width-1 downto 0);
	signal regRESULT	: STD_LOGIC_VECTOR((width*2)-1 downto 0);
	
	signal tmp_null	: STD_LOGIC_VECTOR(width-1 downto 0);
	signal tmp_result	: STD_LOGIC_VECTOR((width*2)-1 downto 0);

begin
	
	tmp_null <= (others => '0');
	
	tmp_result <= (regA) * (regB);
	MUL_out_RESULT <= regRESULT;
	 
	
	reg_io: process is
	begin
	
		wait until rising_edge(CLK);
		if (RST='1') then
			regA <= (others => '0');
			regB <= (others => '0');
			regRESULT <= (others => '0');
			
		else
			regA <= MUL_in_A;
			regB <= MUL_in_B;
			regRESULT <= tmp_result;
		end if;		
		
	end process;
	






end Behavioral;

