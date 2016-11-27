----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     22:01:36 02/25/2010 
-- Design Name:     BIST
-- Module Name:     UUT - Behavioral 
-- Project Name:    Lab5a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Unit Under test. Purely combinational gate network.
--
-- Dependencies:    modn_counter, BIST_Control, romTP, romOUT
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
entity UUT is
    Port ( FLT 		: in  STD_LOGIC_VECTOR (2 downto 0);
           INPUTS 	: in  STD_LOGIC_VECTOR (5 downto 0);
           OUTPUT 	: out  STD_LOGIC);
end UUT;

architecture Behavioral of UUT is

signal A,B,C,D,E,F,G,H,I,J,K,L,Ff,Hf,Jf : STD_LOGIC;
begin

----------------------------------------------------------------------------------
-- Combinational gate network
----------------------------------------------------------------------------------

-- external inputs
A <= INPUTS(0);
B <= INPUTS(1);
C <= INPUTS(2);
D <= INPUTS(3);
E <= INPUTS(4);
F <= INPUTS(5);

-- mechanism for injecting : F s@1
Ff 	<= F OR FLT(0);
G 	<= A AND B;
H 	<= C AND D;
-- mechanism for injecting : H s@0
Hf 	<= H AND (NOT FLT(1));
I 	<= E OR Hf;
J 	<= (G NOR I);
-- mechanism for injecting : J s@1
Jf 	<= J OR FLT(2);
K 	<= I OR Ff;
L 	<= Jf OR K;

OUTPUT <= L;

end Behavioral;

