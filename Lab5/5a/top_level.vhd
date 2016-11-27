----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	22:16:32 02/25/2011 
-- Design Name: 	top level circuit
-- Module Name:    	top_level - Behavioral 
-- Project Name:   	Lab5a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Top Level Circuit, wires up the UUT, BIST, Debouncer and,
--					fault injection mechanism. Able to inject a fault into the
--					system by toggling the bits in the B_FLT signal. The L_ERR
--					and L_ID will notify if the error has been caught by the BIST,
--					and which error number it corresponds to.				
--
-- Dependencies: 	top_level
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
entity top_level is
    Port ( CLK 			: in  STD_LOGIC;
           B_RST 		: in  STD_LOGIC;
           B_TEST 		: in  STD_LOGIC;
           B_FLT 		: in  STD_LOGIC_VECTOR (2 downto 0);
           L_OUT 		: out  STD_LOGIC;
           L_ERR 		: out  STD_LOGIC;
           L_ID 		: out  STD_LOGIC_VECTOR (3 downto 0);
		   TOP_INPUTS 	: in STD_LOGIC_VECTOR(5 downto 0));
end top_level;

architecture Behavioral of top_level is

----------------------------------------------------------------------------------
-- Component Declaration - UUT
----------------------------------------------------------------------------------
	COMPONENT UUT
	PORT(
		FLT 	: IN std_logic_vector(2 downto 0);
		INPUTS 	: IN std_logic_vector(5 downto 0);          
		OUTPUT 	: OUT std_logic
		);
	END COMPONENT;
	
----------------------------------------------------------------------------------
-- Component Declaration - BIST
----------------------------------------------------------------------------------
	COMPONENT BIST
	PORT(
		CLK 		: IN std_logic;
		B_RST 		: IN std_logic;
		B_TEST 		: IN std_logic;
		UUT_OUT 	: IN std_logic;          
		TEST 		: OUT std_logic_vector(5 downto 0);
		MODE 		: OUT std_logic;
		L_ERR 		: OUT std_logic;
		L_ID 		: OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

----------------------------------------------------------------------------------
-- Component Declaration - Debouncer
----------------------------------------------------------------------------------
	COMPONENT Debouncer
	PORT(
		CLK 		: IN std_logic;
		Sig 		: IN std_logic;          
		Deb_Sig 	: OUT std_logic
		);
	END COMPONENT;

----------------------------------------------------------------------------------
-- Temporary signals used for wiring
----------------------------------------------------------------------------------
	
	signal INPUTS, TEST, VECTOR 				: STD_LOGIC_VECTOR (5 downto 0);
	signal B_FLT_DB, B_FLT_SET 					: STD_LOGIC_VECTOR (2 downto 0);
	signal MODE, B_RST_DB, B_TEST_DB, UUT_OUT	: STD_LOGIC;

begin

----------------------------------------------------------------------------------
-- Instantiate the Debouncers
----------------------------------------------------------------------------------
	Inst_Debouncer_RST: Debouncer PORT MAP(
		CLK => CLK,
		Sig => B_RST,
		Deb_Sig => B_RST_DB
	);

	Inst_Debouncer_TEST: Debouncer PORT MAP(
		CLK => CLK,
		Sig => B_TEST,
		Deb_Sig => B_TEST_DB
	);

----------------------------------------------------------------------------------
-- Fault injection mechanism - test and set
----------------------------------------------------------------------------------	
	SET_FAULTS: for i in 0 to 2 generate
	begin
		Inst_Debouncer_FLT: Debouncer PORT MAP(
			CLK => CLK,
			Sig => B_FLT(i),
			Deb_Sig => B_FLT_DB(i)
		);

		SET_FLT: process (CLK) is
		begin
			if (CLK'EVENT and CLK = '1') then
				if B_RST_DB = '1' then
					B_FLT_SET(i) <= '0';
				else
					B_FLT_SET(i) <= B_FLT_SET(i) OR B_FLT_DB(i);
				end if;
			end if;
		end process SET_FLT;
	end generate;

----------------------------------------------------------------------------------
-- Instantiate the UUT
----------------------------------------------------------------------------------	
	Inst_UUT: UUT PORT MAP(
		FLT => B_FLT_SET,
		INPUTS => VECTOR,
		OUTPUT => UUT_OUT
	);

----------------------------------------------------------------------------------
-- Instantiate the BIST
----------------------------------------------------------------------------------	
	Inst_BIST: BIST PORT MAP(
		CLK => CLK,
		B_RST => B_RST_DB,
		B_TEST => B_TEST_DB,
		UUT_OUT => UUT_OUT,
		TEST => TEST,
		MODE => MODE,
		L_ERR => L_ERR,
		L_ID => L_ID
	);
----------------------------------------------------------------------------------
-- Connect the BIST outputs to the UUT inputs, when in test mode (=1)
----------------------------------------------------------------------------------
	VECTOR <= TEST WHEN MODE = '1' ELSE TOP_INPUTS;
	L_OUT <= UUT_OUT;
	
end Behavioral;

