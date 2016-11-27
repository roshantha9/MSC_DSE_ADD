----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     13:49:29 01/31/2011 
-- Design Name:     fibonacci top level circuit
-- Module Name:     fib_toplevel_cir - Behavioral 
-- Project Name:    Lab2c
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Top Level Circuit of the Fibonacci Sequence generator
--
-- Dependencies:    fib_control, RAM16X8S, debounce
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
library UNISIM;
use UNISIM.VComponents.all;

entity fib_toplevel_cir is
	generic (fib_width : NATURAL := 8;
			 ram_width : NATURAL := 4
			);
	port ( COUNT	  : in STD_LOGIC;
		   RESET	  : in STD_LOGIC;
		   CLOCK	  : in STD_LOGIC;
		   FIB_OUT  : out STD_LOGIC_VECTOR(fib_width-1 downto 0)		 
		 );

end fib_toplevel_cir;

architecture behavioral of fib_toplevel_cir is
	signal ram_addr 	 : STD_LOGIC_VECTOR(ram_width-1 downto 0);
	signal ram_output  	 : STD_LOGIC_VECTOR(fib_width-1 downto 0);
	signal ram_input     : STD_LOGIC_VECTOR(fib_width-1 downto 0);
	signal tmp_deb_count : STD_LOGIC;
	--signal tmp_deb_reset : STD_LOGIC;
	
	signal fib_output 	 : STD_LOGIC_VECTOR(fib_width-1 downto 0);
	
	-- fsm related control signals --
	signal fsm_o_pr_state 		: STD_LOGIC_VECTOR(2 downto 0);
	signal fsm_o_ram_wr_en 		: STD_LOGIC;
	signal fsm_o_ram_rd_addr 	: STD_LOGIC_VECTOR(ram_width-1 downto 0);
	signal fsm_o_ram_wr_addr 	: STD_LOGIC_VECTOR(ram_width-1 downto 0);

	
   signal fib_n		: STD_LOGIC_VECTOR(fib_width-1 downto 0); -- nth fibonacci value stored
   signal fib_n_1	: STD_LOGIC_VECTOR(fib_width-1 downto 0); -- (n-1) fibonacci value stored	
   signal fib_nxt	: STD_LOGIC_VECTOR(fib_width-1 downto 0);
   
   signal internal_reset 	: STD_LOGIC;
   signal fib_max_reached 	: STD_LOGIC;
	
begin


----------------------------------------------------------------------------------
-- DISTRIBUTED RAM INSTANTIATION
----------------------------------------------------------------------------------


	-- RAM16X8S: 16 x 8 posedge write distributed  => LUT RAM
   --           Virtex-II/II-Pro
   -- Xilinx HDL Language Template, version 10.1.3

   i_RAM16X8S : RAM16X8S
   generic map (
      INIT_00 => X"0000", --  INIT for bit 0 of RAM
      INIT_01 => X"0000", --  INIT for bit 1 of RAM
      INIT_02 => X"0000", --  INIT for bit 2 of RAM
      INIT_03 => X"0000", --  INIT for bit 3 of RAM
      INIT_04 => X"0000", --  INIT for bit 4 of RAM
      INIT_05 => X"0000", --  INIT for bit 5 of RAM
      INIT_06 => X"0000", --  INIT for bit 6 of RAM
      INIT_07 => X"0000") --  INIT for bit 7 of RAM
   port map (
      O  	=> ram_output,      -- 8-bit RAM data output
      A0 	=> ram_addr(0),     -- RAM address[0] input
      A1	=> ram_addr(1),     -- RAM address[1] input
      A2 	=> ram_addr(2),     -- RAM address[2] input
      A3 	=> ram_addr(3),     -- RAM address[3] input
      D  	=> ram_input,       -- 8-bit RAM data input
      WCLK 	=> CLOCK, -- Write clock input
      WE 	=> fsm_o_ram_wr_en      -- Write enable input
   );

   -- End of RAM16X8S_inst instantiation

----------------------------------------------------------------------------------
-- DEBOUNCER
----------------------------------------------------------------------------------
   
	-- initialising the debounce module for the COUNT user input
	i_debounce_count: entity work.debounce(behavioral)
	port map( D_IN  => COUNT,
			  CLOCK => CLOCK,
			  RESET => RESET,
			  Q_OUT => tmp_deb_count );
				 
	-- * Issue with Debouncing RESET * --
	-- The Debounce unit has a RESET signal. Hence should there be two RESETS ? 
	-- We have a board RESET and another BTN_RESET (Push Button) ? 
	-- OR'ing them will provide the global reset ?
	
	
	--initialising the debounce module for the RESET user input
	-- i_debounce_reset: entity work.debounce(behavioral)
	-- port map( D_IN  => RESET,
			  -- CLOCK => CLOCK,
			  -- RESET => RESET,
			  -- Q_OUT => tmp_deb_reset );


----------------------------------------------------------------------------------
--  FIB CONTROL UNIT (FSM)
----------------------------------------------------------------------------------
	-- instantiate the fibonacci fsm controller
	i_fib_control_1: entity work.fib_control(behavioral)
	generic map( ram_adr_size => ram_width )
	port map(	
				-- inputs --
				CLOCK 	=> CLOCK,
				COUNT_IN =>	tmp_deb_count,
				RESET 	=> RESET,
				MAX_FIB_REACHED => fib_max_reached,
				
				-- outputs --
				PR_STATE 	=> fsm_o_pr_state,		-- present state of the fsm
				RAM_WR_EN   => fsm_o_ram_wr_en,		-- ram write enable signal
				RAM_RD_ADDR => fsm_o_ram_rd_addr,	-- ram read address
				RAM_WR_ADDR	=> fsm_o_ram_wr_addr    -- ram write address				
			);				  	

----------------------------------------------------------------------------------
--  ADDER : FIB_N + FIB_N_1
----------------------------------------------------------------------------------
	-- adder : add the F(n-1) + F(n), where F is the fibonacci sequence
	fib_nxt <= fib_n_1 + fib_n;
	
	-- reset internal regs in state0
	internal_reset <= '1' when fsm_o_pr_state="000" else '0';

----------------------------------------------------------------------------------
--  COMPARATOR : HAS THE MAX FIB VALUE BEING CALCULATED ?
----------------------------------------------------------------------------------
	-- compare fib_nxt and fib_n, produce reset signal accodingly	
	p_cutoff: process is
	begin
	   wait until rising_edge(CLOCK);	
		  -- if next fib is less than current fib value
		  -- then max has been reached, else not reached
		  if ( fib_nxt < fib_n ) then 
			 fib_max_reached <= '1';	
		  else 
			 fib_max_reached <= '0';
		  end if; 
	end process; 

----------------------------------------------------------------------------------
--  REGISTERS FOR FIB_N AND FIB_N_1
----------------------------------------------------------------------------------	
	
	-- register used to save the (n-1) fibonacci number
	-- load new input in state: S2 else hold curr. value
	proc_n_1: process is
	begin
		wait until rising_edge(CLOCK);
		if(RESET='1' or internal_reset='1') then
		--if(RESET='1') then
			fib_n_1 <= (others=>'0');
		else
			if(fsm_o_pr_state = "010") then			
				fib_n_1 <= ram_output;				
			else
				fib_n_1 <= fib_n_1;
			end if;
		end if;
	end process proc_n_1;	
	
	-- register used to save the (n) fibonacci number
	-- load new input in state: S4 else hold curr. value
	proc_n: process is
	begin
		wait until rising_edge(CLOCK);
		if(RESET='1' or internal_reset='1') then
		--if(RESET='1') then
			fib_n <= (others=>'0');
		else	
			if(fsm_o_pr_state = "100") then			
				fib_n <= ram_output;				
			else
				fib_n <= fib_n;
			end if;
		end if;
	end process proc_n;	

----------------------------------------------------------------------------------
--  RAM INPUT SELECTION
----------------------------------------------------------------------------------		
	-- ram input selection (hopefully this will infer a mux)
	ram_input <= (others=>'0') when fsm_o_pr_state="000" else
				 conv_std_logic_vector(1,fib_width) when fsm_o_pr_state = "001" else					 
				 fib_nxt when fsm_o_pr_state="101" else (others=>'0');					 

----------------------------------------------------------------------------------
--  FIB OUTPUT REGISTER AND CONTENT SELECTION, BASED ON PRESENT STATE
----------------------------------------------------------------------------------		
				 
	-- register used to save the (n) fibonacci number
	-- load new input in state: S0, S1, S5, else hold curr. value
	proc_output: process is
	begin
		wait until rising_edge(CLOCK);
		if(RESET='1' or internal_reset='1') then
		--if(RESET='1') then
			fib_output <= (others=>'0');
		else	
			if(fsm_o_pr_state = "000") then		
				fib_output <= ram_input;
			elsif(fsm_o_pr_state = "001") then
				fib_output <= ram_input;
			elsif(fsm_o_pr_state = "101") then
				fib_output <= ram_input;		
			else
				fib_output <= fib_output;
			end if;
		end if;
	end process proc_output;	
							
							
	FIB_OUT <= fib_output;	
	
----------------------------------------------------------------------------------
--  RAM ADDRESS 
----------------------------------------------------------------------------------

	-- ram address is wr_addr when wr_en is high, else take rd_addr
	ram_addr <= fsm_o_ram_wr_addr when fsm_o_ram_wr_en = '1' 
								 else  fsm_o_ram_rd_addr;				 

end behavioral;

