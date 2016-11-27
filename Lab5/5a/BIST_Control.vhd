----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     18:08:40 02/25/2011 
-- Design Name:     BIST Control Unit (FSM)
-- Module Name:     bist_control - Behavioral  
-- Project Name:    Lab5a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     FSM for the BIST, 4 states. Control outputs, control the
--					counters, BIST mode, and error reporting
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
entity BIST_Control is
	port ( 	CNTRL_in_CLK 			: in STD_LOGIC;  -- clock
			CNTRL_in_RST 			: in STD_LOGIC;	 -- reset
			 
			CNTRL_in_TEST 			: in STD_LOGIC;	 -- test button pressed
			CNTRL_in_COMPARE 		: in STD_LOGIC;  -- comparison is true/false
			CNTRL_in_CNTMAX			: in STD_LOGIC;  -- counter max value reached
			 
			CNTRL_out_CNT_EN		: out STD_LOGIC; -- counter enable
			CNTRL_out_MODE			: out STD_LOGIC; -- mode of the UUT =1(test)
			 
			CNTRL_out_REPORT_ERR 	: out STD_LOGIC; -- error detected notify
			CNTRL_out_FINISHED	 	: out STD_LOGIC	 -- finished testing		 
		);
			 
end BIST_Control;

architecture Behavioral of bist_control is

----------------------------------------------------------------------------------
-- State Declaration
----------------------------------------------------------------------------------

type state is (ST_IDLE, ST_TEST, ST_ERR_REP, ST_FINISH);
signal cur_state : state;
			 
begin

----------------------------------------------------------------------------------
-- Determine next state in the FSM
----------------------------------------------------------------------------------
	fsm_nxtstate: process is
	begin
		   wait until rising_edge(CNTRL_in_CLK);
			
			if(CNTRL_in_RST='1') then
				cur_state <= ST_IDLE;
			else	
					case cur_state is				
						
						-- wait in idle state, until test button is pressed
						when ST_IDLE =>														
							
							if (CNTRL_in_TEST='1') then
								cur_state <= ST_TEST;
							else
								cur_state <= ST_IDLE;						
							end if;						
						
						-- if comparison is true, i.e uut output is not equal
						-- to the rom output, then report error, else loop in 
						-- TEST state, until all tests have been exhausted.
						when ST_TEST =>
							
							if (CNTRL_in_COMPARE='1') then
								cur_state <= ST_ERR_REP;
							else
								if(CNTRL_in_CNTMAX='1') then
									cur_state <= ST_FINISH;
								else
									cur_state <= ST_TEST;
								end if;								
							end if;						
						
						-- when error has been detected, stay in current state until
						-- reset has been pressed
						when ST_ERR_REP =>
							cur_state <= ST_ERR_REP;						
						
						-- when all tests have been complete, go back to idle state
						when ST_FINISH =>
							cur_state <= ST_IDLE;										
						
						-- default condition
						when others => 
							cur_state <= ST_IDLE;
							
					end case;						
		   end if;
			
	end process fsm_nxtstate;	
	
----------------------------------------------------------------------------------
-- FSM Control Outputs
----------------------------------------------------------------------------------

	CNTRL_out_CNT_EN		<=	'1' when (cur_state = ST_TEST) else '0';
	CNTRL_out_MODE			<=	'1' when (cur_state = ST_TEST or 
										  cur_state = ST_ERR_REP or 
										  cur_state = ST_FINISH) else '0';			 
	CNTRL_out_REPORT_ERR 	<=	'1' when (cur_state = ST_ERR_REP) else '0';	
	CNTRL_out_FINISHED 		<= '1' when (cur_state = ST_FINISH) else '0';

end Behavioral;

