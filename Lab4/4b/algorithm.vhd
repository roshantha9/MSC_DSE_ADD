----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:33 02/11/2010 
-- Design Name: 
-- Module Name:    algorithm - Behavioral 
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

entity algorithm is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           C : in  STD_LOGIC_VECTOR (15 downto 0);
           D : in  STD_LOGIC_VECTOR (31 downto 0);
			  CLK: in STD_LOGIC;
			  overflow: out STD_LOGIC;
           O : out  STD_LOGIC_VECTOR (63 downto 0));
end algorithm;

architecture Behavioral of algorithm is
	signal INT1 : std_logic_vector(15 downto 0);
	signal INT2 : std_logic_vector(31 downto 0);
	signal INT3 : std_logic_vector(32 downto 0);
	signal INT4 : std_logic_vector(63 downto 0);
	signal INT5 : std_logic_vector(64 downto 0);
	signal INT6 : std_logic_vector(63 downto 0);
	signal overflow1, overflow2: std_logic;
begin

	INT1 <= A - 3;
	
	INT2 <= INT1 * B;

	INT3 <= ('0' & INT2) + ("0000000000000" & C);

	overflow1 <= INT3(32);

	INT4 <= INT3(31 downto 0)*D;
	
	INT5 <= ('0' & INT4) + 5;
	overflow2 <= INT5(64);
	
	int4reg: process (CLK) is
	begin
		if (clk'event and clk = '1') then
			INT6 <= INT5(63 downto 0) - D;
		end if;
	end process;
	
	O <= INT6;
	overflow <= overflow1 or overflow2;


end Behavioral;

