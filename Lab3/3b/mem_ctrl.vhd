----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     21:43:08 02/09/2011 
-- Design Name:     SRAM Memory Controller
-- Module Name:     mem_ctrl - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     SRAM Memory Controller, 
--					S61NLP25636A/IS61NVP25636A
--					S61NLP51218A/IS61NVP51218A
--					Timing and State Transitions according to the data given
--					in lab script and SRAM chip datasheet
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
entity mem_ctrl is
	generic(	N 					: natural := 18;	-- address len
				M 					: natural := 36 	-- word size
		   );

	port( CLK						: in STD_LOGIC;
			RESET				 	: in STD_LOGIC;
			
			-- external inputs --
			MEMCNTRL_in_ADDR		: in STD_LOGIC_VECTOR(N-1 downto 0);		
			MEMCNTRL_in_DATAW 		: in STD_LOGIC_VECTOR(M-1 downto 0);
			MEMCNTRL_in_WRITE 		: in STD_LOGIC;
			MEMCNTRL_in_REQ			: in STD_LOGIC;			
					
			-- outputs --
			--- to the main logic
			MEMCNTRL_out_FINISHED 	: out STD_LOGIC;
			MEMCNTRL_out_DATAR	 	: out STD_LOGIC_VECTOR(M-1 downto 0);
			
			-- to the sram
			MEMCNTRL_out_CLK		: out STD_LOGIC;
			MEMCNTRL_out_ADDRM	 	: out STD_LOGIC_VECTOR(N-1 downto 0);
			MEMCNTRL_out_DATAM	 	: inout STD_LOGIC_VECTOR(M-1 downto 0);
			MEMCNTRL_out_BWn		: out STD_LOGIC_VECTOR(3 downto 0);
			MEMCNTRL_out_Adv	    : out STD_LOGIC;
			MEMCNTRL_out_Mode		: out STD_LOGIC;
			MEMCNTRL_out_OEn		: out STD_LOGIC;
			MEMCNTRL_out_WEn		: out STD_LOGIC;
			MEMCNTRL_out_CEn		: out STD_LOGIC;
			
			-- bringing out state machine current state (for debugging)
			MEMCNTRL_out_CURSTATE	: out STD_LOGIC_VECTOR(2 downto 0));
			
end mem_ctrl;



architecture behavioral of mem_ctrl is

----------------------------------------------------------------------------------
-- component declarations
----------------------------------------------------------------------------------
component mem_ctrl_fsm is
	port(
			CLK 				: in STD_LOGIC;
				
			-- external inputs 
			FSM_in_RESET 		: in STD_LOGIC;
			FSM_in_REQ   		: in STD_LOGIC;
			
			-- internal inputs
			FSM_in_WRITE 		: in STD_LOGIC;
			
			-- output current state
			FSM_out_CUR_STATE 	: out STD_LOGIC_VECTOR(2 downto 0);
			
			-- control outputs
			FSM_out_ADDR_REG_EN : out STD_LOGIC;
			FSM_out_DW_REG_EN  	: out STD_LOGIC;
			FSM_out_CEn			: out STD_LOGIC;
			FSM_out_WEn			: out STD_LOGIC;
			FSM_out_OEn			: out STD_LOGIC;
			FSM_out_DR_REG_EN 	: out STD_LOGIC;
			FSM_out_FINISHED	: out STD_LOGIC		
			);
end component;

----------------------------------------------------------------------------------
-- Temporary signals used for wiring ports
---------------------------------------------------------------------------------- 
signal fsm_cur_state 	: STD_LOGIC_VECTOR(2 downto 0);
signal fsm_addr_reg_en 	: STD_LOGIC;
signal fsm_dw_reg_en   	: STD_LOGIC;
signal fsm_cen			: STD_LOGIC;
signal fsm_wen			: STD_LOGIC; 
signal fsm_oen			: STD_LOGIC;
signal fsm_dr_reg_en   	: STD_LOGIC;
signal fsm_finished	  	: STD_LOGIC;

--signal data_in	  : STD_LOGIC_VECTOR(M-1 downto 0);
signal data_out  		: STD_LOGIC_VECTOR(M-1 downto 0);

signal addr_reg  		: STD_LOGIC_VECTOR(N-1 downto 0);
signal dataw_reg 		: STD_LOGIC_VECTOR(M-1 downto 0);
signal datar_reg 		: STD_LOGIC_VECTOR(M-1 downto 0);

begin

-- clock output to ram unit
MEMCNTRL_out_CLK <= CLK;


----------------------------------------------------------------------------------
-- storage address and data registers 
----------------------------------------------------------------------------------

	-- address register, with clock enable and reset
	p_addr_reg: process is
	begin	
		wait until rising_edge(CLK);	
		if(RESET='1')then
			addr_reg <= (others => '0');
		elsif(fsm_addr_reg_en='1') then
			addr_reg <= MEMCNTRL_in_ADDR;
		else
			addr_reg <= addr_reg;
		end if;
	end process;
	
	MEMCNTRL_out_ADDRM <= addr_reg;

	-- data write register, with clock enable and reset
	p_dataw_reg: process is
	begin	
		wait until rising_edge(CLK);	
		if(RESET='1')then
			dataw_reg <= (others => '0');
		elsif(fsm_dw_reg_en='1') then
			dataw_reg <= MEMCNTRL_in_DATAW;
		else
			dataw_reg <= dataw_reg;
		end if;
	end process;

	data_out <= dataw_reg;

	-- data read register, with clock enable and reset
	p_datar_reg: process is
	begin	
		wait until rising_edge(CLK);	
		if(RESET='1')then
			datar_reg <= (others => '0');
		elsif(fsm_dr_reg_en='1') then
			datar_reg <= MEMCNTRL_out_DATAM;
		else
			datar_reg <= datar_reg;
		end if;
	end process;

	MEMCNTRL_out_DATAR <= datar_reg;


----------------------------------------------------------------------------------
-- Memory Controller - Control Logic
----------------------------------------------------------------------------------
	
	i_mem_ctrl_fsm : mem_ctrl_fsm
	port map(	CLK 				=> CLK,
					
				-- external inputs 
				FSM_in_RESET        => RESET,
				FSM_in_REQ          => MEMCNTRL_in_REQ,
				
				-- internal inputs
				FSM_in_WRITE        => MEMCNTRL_in_WRITE,
				
				-- output current state
				FSM_out_CUR_STATE   => fsm_cur_state,
				
				-- control outputs
				FSM_out_ADDR_REG_EN => fsm_addr_reg_en,
				FSM_out_DW_REG_EN   => fsm_dw_reg_en,
				FSM_out_CEn			=> fsm_cen,
				FSM_out_WEn			=> fsm_wen,
				FSM_out_OEn			=> fsm_oen,
				FSM_out_DR_REG_EN   => fsm_dr_reg_en,
				FSM_out_FINISHED	=> fsm_finished
			  );

	MEMCNTRL_out_FINISHED	<= fsm_finished;	
	MEMCNTRL_out_WEn		<= fsm_wen;
	MEMCNTRL_out_CEn		<= fsm_cen;
	MEMCNTRL_out_OEn 		<= fsm_oen;

----------------------------------------------------------------------------------
-- Fixed Outputs to the SRAM
----------------------------------------------------------------------------------
 
    MEMCNTRL_out_BWn	 	<= "0000";
	MEMCNTRL_out_Adv	 	<= '0';
	MEMCNTRL_out_Mode	 	<= '0';
	

----------------------------------------------------------------------------------
-- Data output bus, high-Z when SRAM is accessing it
----------------------------------------------------------------------------------

	MEMCNTRL_out_DATAM <= data_out when (fsm_oen = '1' 
						and fsm_cur_state="011") -- when the fpga is writing
						else (others => 'Z');	 -- high-Impedance when reading
											 
----------------------------------------------------------------------------------
-- Bringing out signals to the top level to debug
----------------------------------------------------------------------------------

	MEMCNTRL_out_CURSTATE <= fsm_cur_state;
	
	
end behavioral;

