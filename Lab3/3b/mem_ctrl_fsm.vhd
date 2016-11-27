----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     20:38:37 02/09/2011 
-- Design Name:     SRAM Memory Controller
-- Module Name:     mem_ctrl_fsm - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     SRAM Controller FSM (implemented as seperate entity)
--					5 states, more and mealy based.
--
-- Dependencies:    None
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
-- Entity Declation
----------------------------------------------------------------------------------
entity mem_ctrl_fsm is

	port(
			CLK 					: in STD_LOGIC;			
				
			-- external inputs 
			FSM_in_RESET 			: in STD_LOGIC;
			FSM_in_REQ  			: in STD_LOGIC;
			
			-- internal inputs
			FSM_in_WRITE 			: in STD_LOGIC;
			
			-- output current state
			FSM_out_CUR_STATE 		: out STD_LOGIC_VECTOR(2 downto 0);
			
			-- control outputs
			FSM_out_ADDR_REG_EN  	: out STD_LOGIC;
			FSM_out_DW_REG_EN  		: out STD_LOGIC;
			FSM_out_CEn			   	: out STD_LOGIC;
			FSM_out_WEn			   	: out STD_LOGIC;
			FSM_out_OEn				: out STD_LOGIC;
			FSM_out_DR_REG_EN 		: out STD_LOGIC;
			FSM_out_FINISHED		: out STD_LOGIC					
		);

end mem_ctrl_fsm;

architecture Behavioral of mem_ctrl_fsm is
	
	-- 5 states
	type state is (m0, m1, m2, m3, m4);
	signal cur_state : state;
	
begin


----------------------------------------------------------------------------------
-- Output Current State, useful for debugging
----------------------------------------------------------------------------------
-- output current state as bit vector, binary coding
FSM_out_CUR_STATE <= "000" when cur_state = m0 else
							"001" when cur_state = m1 else
							"010" when cur_state = m2 else
							"011" when cur_state = m3 else
							"100" when cur_state = m4 else "111";



----------------------------------------------------------------------------------
-- Determine next state in the FSM
----------------------------------------------------------------------------------
	fsm_nxtstate: process is
	begin
		   wait until rising_edge(CLK);
			
			if(FSM_in_RESET='1') then
				cur_state <= m0;
			else	
					case cur_state is				
						
						-- idle, wait until request has been made
						when m0 =>
							if(FSM_in_REQ='1') then
								cur_state <= m1;
							else
								cur_state <= m0;
							end if;				
						when m1 =>
							cur_state <= m2;			
						when m2 =>
							cur_state <= m3;				
						when m3 =>
							cur_state <= m4;							
						when m4 =>				
							cur_state <= m0;
						when others => cur_state <= m0;
						
					end case;			
		   end if;
			
	end process fsm_nxtstate;
	
----------------------------------------------------------------------------------
-- FSM state outputs, mealy and moore based
----------------------------------------------------------------------------------	
	
	FSM_out_ADDR_REG_EN <= '1' when (cur_state=m0 and FSM_in_REQ='1')  else '0';
	FSM_out_DW_REG_EN   <= '1' when (cur_state=m1 and FSM_in_WRITE='1') else '0';
	FSM_out_CEn			<= '0' when (cur_state=m1) else '1';
	FSM_out_WEn			<= '0' when (cur_state=m1 and FSM_in_WRITE='1') else '1';
	FSM_out_OEn			<= '0' when (cur_state=m3 and FSM_in_WRITE='0') else '1';	
	FSM_out_DR_REG_EN   <= '1' when (cur_state=m3 and FSM_in_WRITE='0') else '0';
	FSM_out_FINISHED	<= '1' when (cur_state=m4) else '0';			

end Behavioral;

