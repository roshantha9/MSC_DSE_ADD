----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     13:32:18 02/14/2011 
-- Design Name:     SRAM Memory Controller - Test Bench
-- Module Name:     mem_ctrl_tb.vhd - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Produces two write cycles and two read cycles, 
--					request, write, address and data lines are hardcoded.					
--					
-- Dependencies:    mem_ctrl, sram
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
 
ENTITY mem_ctrl_tb IS
END mem_ctrl_tb;
 
ARCHITECTURE behavior OF mem_ctrl_tb IS

----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
	 constant NN 			: natural := 8;
	 constant MM 			: natural := 36;
	 constant clk_period 	:time := 10ns;
 
 
----------------------------------------------------------------------------------
-- Component Declaration - SRAM (UUT1)
---------------------------------------------------------------------------------- 
     component SRAM
		 generic ( word_len : NATURAL := MM;	-- word size
				   adr_size : NATURAL := NN		-- address size		   
				 );
		 port(
				SRAM_CLK 		: IN  std_logic;
				SRAM_ADDR_M 	: IN  std_logic_vector(NN-1 downto 0);
				SRAM_DATA_M 	: INOUT  std_logic_vector(MM-1 downto 0);
				SRAM_CEn 		: IN  std_logic;
				SRAM_OEn 		: IN  std_logic;
				SRAM_WEn 		: IN  std_logic
			  );
    end component;
	 
----------------------------------------------------------------------------------
-- Component Declaration - mem_ctrl (UUT2)
----------------------------------------------------------------------------------  
	 component mem_ctrl	 
		generic(	N 					: natural := NN;
					M 					: natural := MM 
			   );
		port( 	CLK						: in STD_LOGIC;
				RESET					: in STD_LOGIC;
				
				-- external inputs --
				MEMCNTRL_in_ADDR		: in STD_LOGIC_VECTOR(NN-1 downto 0);		
				MEMCNTRL_in_DATAW 		: in STD_LOGIC_VECTOR(MM-1 downto 0);
				MEMCNTRL_in_WRITE 		: in STD_LOGIC;
				MEMCNTRL_in_REQ			: in STD_LOGIC;			
						
				-- outputs --
				--- to the main logic
				MEMCNTRL_out_FINISHED 	: out STD_LOGIC;
				MEMCNTRL_out_DATAR	 	: out STD_LOGIC_VECTOR(MM-1 downto 0);
				
				-- to the sram
				MEMCNTRL_out_CLK		: out STD_LOGIC;
				MEMCNTRL_out_ADDRM	 	: out STD_LOGIC_VECTOR(NN-1 downto 0);
				MEMCNTRL_out_DATAM	 	: inout STD_LOGIC_VECTOR(MM-1 downto 0);
				MEMCNTRL_out_BWn		: out STD_LOGIC_VECTOR(3 downto 0);
				MEMCNTRL_out_Adv	    : out STD_LOGIC;
				MEMCNTRL_out_Mode		: out STD_LOGIC;
				MEMCNTRL_out_OEn		: out STD_LOGIC;
				MEMCNTRL_out_WEn		: out STD_LOGIC;
				MEMCNTRL_out_CEn		: out STD_LOGIC);			
		end component;
    
----------------------------------------------------------------------------------
-- Temporary Signals used to wiring up the uuts
---------------------------------------------------------------------------------- 
   --Inputs
	signal CLK_TB 	 				: STD_LOGIC := '0';
	signal RESET_TB 				: STD_LOGIC := '0';
	-- mem ctrl inputs
	signal MEMCNTRL_in_ADDR_TB		: STD_LOGIC_VECTOR(NN-1 downto 0) := (others => '0');		
	signal MEMCNTRL_in_DATAW_TB 	: STD_LOGIC_VECTOR(MM-1 downto 0) := (others => '0');
	signal MEMCNTRL_in_WRITE_TB 	: STD_LOGIC := '0';
	signal MEMCNTRL_in_REQ_TB		: STD_LOGIC := '0';
	
	-- mem ctrl outputs
	signal MEMCNTRL_out_FINISHED_TB : STD_LOGIC;
	signal MEMCNTRL_out_DATAR_TB	: STD_LOGIC_VECTOR(MM-1 downto 0);
	
    signal MEMCNTRL_out_CLK_TB		: STD_LOGIC;
	signal MEMCNTRL_out_ADDRM_TB	: STD_LOGIC_VECTOR(NN-1 downto 0);
	signal MEMCNTRL_out_BWn_TB		: STD_LOGIC_VECTOR(3 downto 0);
	signal MEMCNTRL_out_Adv_TB	    : STD_LOGIC;
	signal MEMCNTRL_out_Mode_TB	 	: STD_LOGIC;
	signal MEMCNTRL_out_OEn_TB		: STD_LOGIC;
	signal MEMCNTRL_out_WEn_TB		: STD_LOGIC;
	signal MEMCNTRL_out_CEn_TB		: STD_LOGIC;		
	
	--BiDirs
   signal DATA_M_TB : STD_LOGIC_VECTOR(MM-1 downto 0);	
 
BEGIN

----------------------------------------------------------------------------------
-- Instantiate SRAM (UUT1)
---------------------------------------------------------------------------------- 
   uut1: SRAM 
		generic map ( word_len => MM,	-- word size
					  adr_size => NN	-- address size
					)
		port map (
				  SRAM_CLK 		=> MEMCNTRL_out_CLK_TB,
				  SRAM_ADDR_M 	=> MEMCNTRL_out_ADDRM_TB,
				  SRAM_DATA_M 	=> DATA_M_TB,
				  SRAM_CEn 		=> MEMCNTRL_out_CEn_TB,
				  SRAM_OEn 		=> MEMCNTRL_out_OEn_TB,
				  SRAM_WEn 		=> MEMCNTRL_out_WEn_TB
        );
	
----------------------------------------------------------------------------------
-- Instantiate mem_controller (UUT2)
---------------------------------------------------------------------------------- 
	
	uut2: mem_ctrl
			generic map(
					N 					=>	 NN,		-- word size
					M 					=>	 MM 		-- address size
				)
			port map (
				CLK						=>	 CLK_TB,
				RESET					=>  RESET_TB, 
				
				-- external inputs --
				MEMCNTRL_in_ADDR		=> MEMCNTRL_in_ADDR_TB,
				MEMCNTRL_in_DATAW		=> MEMCNTRL_in_DATAW_TB,
				MEMCNTRL_in_WRITE 		=> MEMCNTRL_in_WRITE_TB,
				MEMCNTRL_in_REQ			=> MEMCNTRL_in_REQ_TB,
						
				-- outputs --
				--- to the main logic
				MEMCNTRL_out_FINISHED 	=> MEMCNTRL_out_FINISHED_TB,
				MEMCNTRL_out_DATAR	 	=> MEMCNTRL_out_DATAR_TB,
				
				-- to the sram
				MEMCNTRL_out_CLK		=> MEMCNTRL_out_CLK_TB,
				MEMCNTRL_out_ADDRM	 	=> MEMCNTRL_out_ADDRM_TB,
				MEMCNTRL_out_DATAM	 	=> DATA_M_TB,
				MEMCNTRL_out_BWn		=> MEMCNTRL_out_BWn_TB,
				MEMCNTRL_out_Adv	    => MEMCNTRL_out_Adv_TB,
				MEMCNTRL_out_Mode		=> MEMCNTRL_out_Mode_TB,
				MEMCNTRL_out_OEn		=> MEMCNTRL_out_OEn_TB,
				MEMCNTRL_out_WEn		=> MEMCNTRL_out_WEn_TB,
				MEMCNTRL_out_CEn		=> MEMCNTRL_out_CEn_TB
			);

----------------------------------------------------------------------------------
-- Clock generation
----------------------------------------------------------------------------------

   clk_process :process
   begin
		CLK_TB <= '0';
		wait for clk_period/2;
		CLK_TB <= '1';
		wait for clk_period/2;
   end process;
 
----------------------------------------------------------------------------------
-- Main stimulus process, 2 write cycles, then 2 read cycles.
-- NB: waiting 6 cycles before requests, because thats how long one request 
--	   takes to complete
----------------------------------------------------------------------------------
   
   stim_proc: process
   begin		
		-- hold reset state for 100 ns.
		RESET_TB <= '1';
		wait for 100 ns;
		RESET_TB <= '0';		

		wait for clk_period*10;

		-- two write cycles
		-- write cycle 1 : write val = 20, addr=0
		MEMCNTRL_in_ADDR_TB  <= conv_std_logic_vector(0, NN);
		MEMCNTRL_in_DATAW_TB <= conv_std_logic_vector(20, MM);
		MEMCNTRL_in_WRITE_TB <= '1';
		MEMCNTRL_in_REQ_TB   <= '1';
		wait for clk_period;
		--MEMCNTRL_in_WRITE_TB <= '0';
		MEMCNTRL_in_REQ_TB   <= '0';		
		
		wait for clk_period*6;
		
		-- write cycle 2 : write val = 40, addr=1
		MEMCNTRL_in_ADDR_TB  <= MEMCNTRL_in_ADDR_TB + 1;
		MEMCNTRL_in_DATAW_TB <= MEMCNTRL_in_DATAW_TB + 20;
		MEMCNTRL_in_WRITE_TB <= '1';
		MEMCNTRL_in_REQ_TB   <= '1';
		wait for clk_period;
		--MEMCNTRL_in_WRITE_TB <= '0';
		MEMCNTRL_in_REQ_TB   <= '0';
		
		wait for clk_period*6;		
		
		-- two read cycles
		-- read cycle 1
		MEMCNTRL_in_ADDR_TB  <= conv_std_logic_vector(0, NN);	
		MEMCNTRL_in_WRITE_TB <= '0';
		MEMCNTRL_in_REQ_TB   <= '1';
		wait for clk_period;
		MEMCNTRL_in_REQ_TB   <= '0';		
		
		wait for clk_period*6;
		
		-- read cycle 2
		MEMCNTRL_in_ADDR_TB  <= MEMCNTRL_in_ADDR_TB + 1;		
		MEMCNTRL_in_REQ_TB   <= '1';
		wait for clk_period;
		MEMCNTRL_in_REQ_TB   <= '0';		
		
		wait for clk_period*6;
		
      wait;
   end process;

END;
