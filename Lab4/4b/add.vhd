----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:29:46 02/21/2011 
-- Design Name: 
-- Module Name:    add - Behavioral 
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

entity add is
	generic( width : natural := 32);
	port ( CLK, RST		: in STD_LOGIC;
			 ADD_in_A		: in STD_LOGIC_VECTOR(width-1 downto 0);
			 ADD_in_B		: in STD_LOGIC_VECTOR(width-1 downto 0);
			 ADD_out_SUM 	: out STD_LOGIC_VECTOR(width-1 downto 0);
			 ADD_out_COUT	: out STD_LOGIC
	);
end add;


architecture Behavioral of add is

signal tmp_sum : STD_LOGIC_VECTOR(width downto 0);

signal regA		: STD_LOGIC_VECTOR(width-1 downto 0);
signal regB		: STD_LOGIC_VECTOR(width-1 downto 0);
signal regSUM	: STD_LOGIC_VECTOR(width-1 downto 0);
signal regCOUT	: STD_LOGIC;


begin

	tmp_sum <= ('0' & regA) + ('0' & regB);
	
	ADD_out_SUM  <= regSUM;
	ADD_out_COUT <= regCOUT;
	
	reg_io: process is
	begin
	
		wait until rising_edge(CLK);
		if (RST='1') then
			regA <= (others => '0');
			regB <= (others => '0');
			regSUM <= (others => '0');
			regCOUT <= '0';
		else
			regA <= ADD_in_A;
			regB <= ADD_in_B;
			regSUM <= tmp_sum(width-1 downto 0);
			regCOUT <= tmp_sum(width);
		end if;		
		
	end process;
	

end Behavioral;

