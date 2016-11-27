----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     00:35:57 02/07/2011 
-- Design Name:     Matrix Multiplication Controller
-- Module Name:     mat_mul_controller - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     13 states, control outputs - used to control the mat_mul unit
--					counter operations and intemediate register operation + SRAM
--					interface signals
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
-- Entity Declaration
----------------------------------------------------------------------------------
entity mat_mul_controller is

	port(
			CLK : in STD_LOGIC;
				
			-- external inputs 
			FSM_in_RESET 		 	: in STD_LOGIC;
			FSM_in_CALC  		 	: in STD_LOGIC;
			FSM_in_DISPLAY 		 	: in STD_LOGIC;
			
			-- internal inputs
			FSM_in_CNT_Ax_DONE 	 	: in STD_LOGIC;
			FSM_in_CALC_COMPLETE 	: in STD_LOGIC;
			
			-- intput from sram controller
			FSM_in_SRAM_FINISHED 	: in STD_LOGIC;
			
			-- control outputs
			FSM_out_CNTAm_EN  	 	: out STD_LOGIC;
			FSM_out_CNTAm_RST 	 	: out STD_LOGIC;			
			FSM_out_CNTAx_RST 	 	: out STD_LOGIC;		
			FSM_out_CNTBy_RST 	 	: out STD_LOGIC;			
			FSM_out_CNT_RCADR_INC 	: out STD_LOGIC;			
			FSM_out_RAMC_WR_EN 		: out STD_LOGIC_VECTOR(0 downto 0);			
			FSM_out_MACC_EN 		: out STD_LOGIC;
			FSM_out_MACC_RST 		: out STD_LOGIC;			
			FSM_out_PROD_REG_EN 	: out STD_LOGIC;			
			
			--- controls to sram controller
			FSM_out_SRAM_REQ	 	: out STD_LOGIC;
			FSM_out_SRAM_WRITE 		: out STD_LOGIC;
			FSM_out_SRAM_RDWR_FLAG 	: out STD_LOGIC; -- 1=wr, 0=rd
			FSM_out_SRAM_RDP_INC 	: out STD_LOGIC
		
		);
end mat_mul_controller;

architecture behavioral of mat_mul_controller is

----------------------------------------------------------------------------------
-- State Declaration : vhdl custom types
----------------------------------------------------------------------------------
	type state is (s0, s1, s2, s3, s4, s5, s6, 
				   s7, s8, s9, s10, s11, s12);
	signal cur_state : state;

begin

----------------------------------------------------------------------------------
-- Main Process : 13 states, S0: reset/idle state
----------------------------------------------------------------------------------
		
	-- determine next state in the FSM
	fsm_nxtstate: process is
	begin
		   wait until rising_edge(CLK);
			-- global synchrounous reset
			if(FSM_in_RESET='1') then
				cur_state <= s0;
			else	
					case cur_state is				
						-- S0: Idle state, waits for CALC (push button press)
						when s0 =>
							if(FSM_in_CALC='1') then
								cur_state <= s1;
							else
								cur_state <= s0;
							end if;				
						
						-- S1: Increment Counter CAm.
						when s1 =>
							cur_state <= s2;
						
						-- S2: Keep incrementing Counter CAm until it’s 
						-- Max flag is asserted (CNT_Am_DONE)
						when s2 =>	-- wait till first row has been completed
							if(FSM_in_CNT_Ax_DONE='1') then
								cur_state <= s3;
							else
								cur_state <= s2;
							end if;
						
						-- S3: Reset CAm, Enable MACC.
						when s3 =>
							cur_state <= s4;
						
						-- S4: Enable MACC
						when s4 =>				
							cur_state <= s5;
						
						-- S5: MACC unit is RESET
						when s5 =>			
							cur_state <= s6;
							
						-- S6: Counter C_ADR is incremented. 
						-- SRAM REQ is asserted, SRAM_WRITE is high.
						when s6 =>
							cur_state <= s7;
							
						-- S7: WAIT state. SRAM_WRITE is high in this state. 
						-- Idle until SRAM_FINISHED is received from the SRAM Controller. 
						-- When SRAM_FINISHED is asserted, a check on the CALC_COMPLETE 
						-- signal is made and if true, transitions to S8. If CALC_COMPLETE 
						-- is false, the machine is looped back to S1, to calculate the 
						-- next prod. co-eff. 	
							
						when s7 =>	
							if(FSM_in_SRAM_FINISHED='1') then
								if(FSM_in_CALC_COMPLETE='1') then
									cur_state <= s8;
								else
									cur_state <= s1;
								end if;							
							else
								cur_state <= s7;
							end if;
							
						-- S8: No outputs, just gives a 1 cycle delay, displays LED to 
						-- indicate Multiplication Complete.
						when s8 =>	-- display mul. comp led light
							cur_state <= s9;
							
						-- S9: WAIT in this state until DISPLAY button has been pressed
						when s9 =>
							if (FSM_in_DISPLAY = '1') then
								cur_state <= s10;
							else	
								cur_state <= s9;
							end if;
						-- S10: Assert SRAM_REQ, SRAM_WRITE is LOW, hence a Read request.
						when s10 =>
							cur_state <= s11;
						
						-- S11: WAIT in this state until SRAM_FINISHED signal is received
						-- from the SRAM_Controller. 
						when s11 =>	-- wait until finished reading from sram
							if(FSM_in_SRAM_FINISHED='1') then
								cur_state <= s12;
							else
								cur_state <= s11;
							end if;
							
						-- S12: Display retrieved value from SRAM, onto the board LEDs.
						when s12 => 						
								cur_state <= s9;
								
						-- handle default state, go to s0
						when others => cur_state <= s0;

						
					end case;			
		   end if;
			
	end process fsm_nxtstate;
	
	
----------------------------------------------------------------------------------
-- state outputs - all are moore based
----------------------------------------------------------------------------------
	FSM_out_CNTAm_EN  <= '1' when (cur_state=s1) or (cur_state=s2) else '0';
	FSM_out_CNTAm_RST <= '1' when (cur_state=s0) else '0';
	FSM_out_CNTAx_RST <= '1' when (cur_state=s0) else '0';
	FSM_out_CNTBy_RST <= '1' when (cur_state=s0) else '0';	
	FSM_out_MACC_EN   <= '1' when (cur_state=s2) or
								  (cur_state=s3) or
								  (cur_state=s4) or
								  (cur_state=s5) else '0';											 
	FSM_out_CNT_RCADR_INC 	<= '1' when (cur_state=s6) else '0';			
	FSM_out_RAMC_WR_EN 		<= "1" when (cur_state=s6) else "0";	
	FSM_out_MACC_RST 		<= '1' when (cur_state=s0) or
							            (cur_state=s5) else '0';	
	FSM_out_PROD_REG_EN 	<= '1' when (cur_state=s5) else '0';	
	FSM_out_SRAM_REQ 		<= '1' when (cur_state=s6 or cur_state=s10) 
								   else '0';
	FSM_out_SRAM_WRITE 		<= '1' when (cur_state=s6 or cur_state=s7) else '0';								
	
	FSM_out_SRAM_RDWR_FLAG 	<= '1' when (cur_state=s6 or cur_state=s7) 
							       else '0';											
	FSM_out_SRAM_RDP_INC 	<= '1' when (cur_state=s12) else '0';
	
end behavioral;

