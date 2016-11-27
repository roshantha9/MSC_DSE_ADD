----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     22:23:37 02/14/2011 
-- Design Name:     Matrix Multiplication Unit
-- Module Name:     toplevel - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     The top level circuit houses the main_logic unit and the
--					mem_ctrl unit(SRAM Memory Controller). relevent SRAM control
--					signals are output. The push button inputs are the main 
--					inputs to this circuit - these are fed to the debounce.
--
-- Dependencies:    main_logic, mem_ctrl
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

----------------------------------------------------------------------------------
-- Entity Declation
----------------------------------------------------------------------------------
entity toplevel is
	
	generic(
				-- matrix size
				m 					: natural := 3;
				x 					: natural := 4;
				y 					: natural := 5;				 
				-- ram size
				ram_addr_size 		: natural := 4;
				ram_data_width 		: natural := 8;
				ram_c_addr_size 	: natural := 8;
				ram_c_data_width 	: natural := 48;
				sram_N 				: natural := 18;
				sram_M 				: natural := 36				
				-- macc unit size
				macc_data_size_a 	: natural := 18;
				macc_data_size_b 	: natural := 18;
				macc_data_size_c 	: natural := 48;
				macc_data_size_p 	: natural := 48;
				-- truncated result size
				result_width 		: natural := 7;				
			);   
   port(
				TOP_in_CLK 			: in STD_LOGIC;	
	
				-- push buttons
				TOP_in_BTN_CALC 	: in STD_LOGIC;
				TOP_in_BTN_RST  	: in STD_LOGIC;
				TOP_in_BTN_DISP 	: in STD_LOGIC;
				
				-- led display
				TOP_out_COMPLETE	: out STD_LOGIC;
				-- 7 bit output to remaining led lights
				TOP_out_SRAMDATA   	: out STD_LOGIC_VECTOR(6 downto 0); 
				
				-- output to sram				
				TOP_MEMCNTRL_out_CLK	: out STD_LOGIC;
				TOP_MEMCNTRL_out_ADDRM	: out STD_LOGIC_VECTOR(sram_N-1 downto 0);
				TOP_MEMCNTRL_out_DATAM	: inout STD_LOGIC_VECTOR(sram_M-1 downto 0);
				TOP_MEMCNTRL_out_BWn	: out STD_LOGIC_VECTOR(3 downto 0);
				TOP_MEMCNTRL_out_Adv	: out STD_LOGIC;
				TOP_MEMCNTRL_out_Mode	: out STD_LOGIC;
				TOP_MEMCNTRL_out_OEn	: out STD_LOGIC;
				TOP_MEMCNTRL_out_WEn	: out STD_LOGIC;
				TOP_MEMCNTRL_out_CEn	: out STD_LOGIC
		);	
	
end toplevel;

architecture behavioral of toplevel is

----------------------------------------------------------------------------------
-- Component Declaration : main_logic 
--						   (houses the mat_mul, mat_mul_controller, debounce)
----------------------------------------------------------------------------------
	component main_logic
		generic ( 
					 -- matrix size
					 m 					: natural := m;
					 x 					: natural := x;
					 y 					: natural := y;				 
					 -- ram size
					 ram_addr_size 		: natural := ram_addr_size;
					 ram_data_width 	: natural := ram_data_width;
					 ram_c_addr_size 	: natural := ram_c_addr_size;
					 ram_c_data_width 	: natural := ram_c_data_width;
					 sram_N 			: natural := sram_N;
					 sram_M 			: natural := sram_M
					 -- macc unit size
					 macc_data_size_a 	: natural := macc_data_size_a;
					 macc_data_size_b 	: natural := macc_data_size_b;
					 macc_data_size_c 	: natural := macc_data_size_c;
					 macc_data_size_p 	: natural := macc_data_size_p;
					 -- truncated result size
					 result_width : natural := result_width;					 
				  );
		port (
					CLK 					: in STD_LOGIC;
					
					-- button presses --
					ML_in_BTN_RESET 		: in STD_LOGIC;
					ML_in_BTN_CALC  		: in STD_LOGIC;
					ML_in_BTN_DISP			: in STD_LOGIC;
					
					-- outputs --
					ML_out_PRD_COEF_TRUNC 	: out STD_LOGIC_VECTOR(result_width-1 downto 0);
					ML_out_CALC_COMPLETE  	: out STD_LOGIC;				

					-- memory controller related  --
					-- outputs
					ML_SRAMMC_out_ADDR		: out STD_LOGIC_VECTOR(sram_N-1 downto 0);		
					ML_SRAMMC_out_DATAW 	: out STD_LOGIC_VECTOR(sram_M-1 downto 0);
					ML_SRAMMC_out_WRITE 	: out STD_LOGIC;
					ML_SRAMMC_out_REQ		: out STD_LOGIC;
					
					-- inputs
					ML_SRAMMC_in_FINISHED	: in STD_LOGIC
				
				);
	end component;
	
----------------------------------------------------------------------------------
-- Component Declaration : mem_ctrl (SRAM Memory Controller)
----------------------------------------------------------------------------------
	component mem_ctrl
		  generic(	N 			: natural := sram_N; -- address size
					M 			: natural := sram_M  -- word length
				 );

		  port( 
					CLK						: in STD_LOGIC;
					RESET				   	: in STD_LOGIC;
					
					-- external inputs --
					MEMCNTRL_in_ADDR		: in STD_LOGIC_VECTOR(sram_N-1 downto 0);		
					MEMCNTRL_in_DATAW 		: in STD_LOGIC_VECTOR(sram_M-1 downto 0);
					MEMCNTRL_in_WRITE 		: in STD_LOGIC;
					MEMCNTRL_in_REQ			: in STD_LOGIC;			
							
					-- outputs --
					--- to the main logic
					MEMCNTRL_out_FINISHED 	: out STD_LOGIC;
					MEMCNTRL_out_DATAR	 	: out STD_LOGIC_VECTOR(sram_M-1 downto 0);
					
					-- to the sram
					MEMCNTRL_out_CLK		: out STD_LOGIC;
					MEMCNTRL_out_ADDRM	 	: out STD_LOGIC_VECTOR(sram_N-1 downto 0);
					MEMCNTRL_out_DATAM	 	: inout STD_LOGIC_VECTOR(sram_M-1 downto 0);
					MEMCNTRL_out_BWn		: out STD_LOGIC_VECTOR(3 downto 0);
					MEMCNTRL_out_Adv	    : out STD_LOGIC;
					MEMCNTRL_out_Mode		: out STD_LOGIC;
					MEMCNTRL_out_OEn		: out STD_LOGIC;
					MEMCNTRL_out_WEn		: out STD_LOGIC;
					MEMCNTRL_out_CEn		: out STD_LOGIC;
					
					-- bringing out state machine current state (for debugging)
					MEMCNTRL_out_CURSTATE	 : out STD_LOGIC_VECTOR(2 downto 0)
				);
	end component;
	
	
	
	--------------------------------------------------
	-- CHIPSCOPE RELATED : used for DEBUGGING
	--------------------------------------------------

	component debug is
	  port (
		CLK 		: in STD_LOGIC := 'X'; 
		CONTROL 	: inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
		TRIG0 		: in STD_LOGIC_VECTOR ( 1 downto 0 ); 
		DATA 		: in STD_LOGIC_VECTOR ( 511 downto 0 ) 
	  );
	end component;
	 
	component scope is
	  port (
		CONTROL0 	: inout STD_LOGIC_VECTOR ( 35 downto 0 ) 
	  );
	end component;

----------------------------------------------------------------------------------
-- Temporary signals - used for wiring
---------------------------------------------------------------------------------- 		
	-- main logic outputs (ML_)
	signal ML_out_PRD_COEF_TRUNC_SIG : STD_LOGIC_VECTOR(result_width-1 downto 0);
	signal ML_out_CALC_COMPLETE_SIG  : STD_LOGIC;	
	signal ML_SRAMMC_out_ADDR	  	 : STD_LOGIC_VECTOR(sram_N-1 downto 0);		
	signal ML_SRAMMC_out_DATAW   	 : STD_LOGIC_VECTOR(sram_M-1 downto 0);
	signal ML_SRAMMC_out_WRITE   	 : STD_LOGIC;
	signal ML_SRAMMC_out_REQ	  	 : STD_LOGIC;
	
	-- outputs from the memory controller (MEMCNTRL_)
	signal MEMCNTRL_out_DATAR	  	 : STD_LOGIC_VECTOR(sram_M-1 downto 0);
	signal MEMCNTRL_out_FINISHED 	 : STD_LOGIC;	
	signal MEMCNTRL_out_CLK		 	 : STD_LOGIC;
	signal MEMCNTRL_out_ADDRM	 	 : STD_LOGIC_VECTOR(sram_N-1 downto 0);
	signal MEMCNTRL_out_BWn		 	 : STD_LOGIC_VECTOR(3 downto 0);
	signal MEMCNTRL_out_Adv	    	 : STD_LOGIC;
	signal MEMCNTRL_out_Mode	 	 : STD_LOGIC;
	signal MEMCNTRL_out_OEn		 	 : STD_LOGIC;
	signal MEMCNTRL_out_WEn		 	 : STD_LOGIC;
	signal MEMCNTRL_out_CEn		 	 : STD_LOGIC;
	
	signal temp_memcntrl_datar	 	 : STD_LOGIC_VECTOR(sram_M-1 downto 0);
	
	-- memcntroller, curstate for debug purposes
	signal MEMCNTRL_out_CURSTATE 	 : STD_LOGIC_VECTOR(2 downto 0);
	signal icon_control0 			 : STD_LOGIC_VECTOR(35 downto 0);
	signal ila_trigger0	 			 : STD_LOGIC_VECTOR(1 downto 0);
	signal ila_datain	 			 : STD_LOGIC_VECTOR(511 downto 0);

begin

----------------------------------------------------------------------------------
-- Instance of the main_logic component
---------------------------------------------------------------------------------- 

		i_main_logic: main_logic
		generic map( 
						 -- matrix size
						 m => m,
						 x => x,
						 y => y,	 
						 -- ram size
						 ram_addr_size => ram_addr_size,
						 ram_data_width => ram_data_width,
						 ram_c_addr_size => ram_c_addr_size,
						 ram_c_data_width => ram_c_data_width,
						 sram_N => sram_N,
						 sram_M => sram_M
						 -- macc unit
						 macc_data_size_a => macc_data_size_a,
						 macc_data_size_b => macc_data_size_b,
						 macc_data_size_c => macc_data_size_c,
						 macc_data_size_p => macc_data_size_p,
						 -- truncated result size
						 result_width => result_width,						 
					  )
		port map(
					CLK 					=> TOP_in_CLK,
					
					-- button presses --
					ML_in_BTN_RESET 		=> TOP_in_BTN_RST,
					ML_in_BTN_CALC 			=> TOP_in_BTN_CALC,
					ML_in_BTN_DISP	 		=> TOP_in_BTN_DISP,
					
					-- outputs --
					ML_out_PRD_COEF_TRUNC 	=> ML_out_PRD_COEF_TRUNC_SIG,
					ML_out_CALC_COMPLETE  	=> ML_out_CALC_COMPLETE_SIG,			

					-- memory controller related  --
					-- outputs
					ML_SRAMMC_out_ADDR		=>	ML_SRAMMC_out_ADDR,	
					ML_SRAMMC_out_DATAW 	=> ML_SRAMMC_out_DATAW,
					ML_SRAMMC_out_WRITE 	=> ML_SRAMMC_out_WRITE,
					ML_SRAMMC_out_REQ		=> ML_SRAMMC_out_REQ,
					
					-- inputs
					ML_SRAMMC_in_FINISHED	=> MEMCNTRL_out_FINISHED
				);
				
	  TOP_out_COMPLETE <= ML_out_CALC_COMPLETE_SIG;	
	  
----------------------------------------------------------------------------------
-- Instance of the mem_ctrl component
---------------------------------------------------------------------------------- 		
		
	  i_mem_ctrl: mem_ctrl
	  generic map(	N 		=> sram_N, -- addr size
					M 		=> sram_M  -- word length
				 ) 
	  port map( 
				CLK					=> TOP_in_CLK,
				RESET				=> TOP_in_BTN_RST,
				
				-- external inputs --
				MEMCNTRL_in_ADDR		=>	ML_SRAMMC_out_ADDR,
				MEMCNTRL_in_DATAW 		=> ML_SRAMMC_out_DATAW,
				MEMCNTRL_in_WRITE 		=>	ML_SRAMMC_out_WRITE,
				MEMCNTRL_in_REQ			=>	ML_SRAMMC_out_REQ,
						
				-- outputs --
				--- to the main logic
				MEMCNTRL_out_FINISHED 	=> MEMCNTRL_out_FINISHED,
				MEMCNTRL_out_DATAR	  	=> MEMCNTRL_out_DATAR,
				
				-- to the sram
				MEMCNTRL_out_CLK	 	=>	MEMCNTRL_out_CLK,
				MEMCNTRL_out_ADDRM	 	=>	MEMCNTRL_out_ADDRM,
				MEMCNTRL_out_DATAM	 	=>	TOP_MEMCNTRL_out_DATAM,
				MEMCNTRL_out_BWn	 	=>	MEMCNTRL_out_BWn,
				MEMCNTRL_out_Adv	 	=>	MEMCNTRL_out_Adv,
				MEMCNTRL_out_Mode	 	=>	MEMCNTRL_out_Mode,
				MEMCNTRL_out_OEn	 	=>	MEMCNTRL_out_OEn,
				MEMCNTRL_out_WEn	 	=>	MEMCNTRL_out_WEn,
				MEMCNTRL_out_CEn	 	=>	MEMCNTRL_out_CEn,
				
				-- debugging
				MEMCNTRL_out_CURSTATE 	=> MEMCNTRL_out_CURSTATE				
			);			
			
			TOP_MEMCNTRL_out_CLK	 <= MEMCNTRL_out_CLK;
			--TOP_MEMCNTRL_out_CLK	<= TOP_in_CLK;
			TOP_MEMCNTRL_out_ADDRM	 <= MEMCNTRL_out_ADDRM;
			TOP_MEMCNTRL_out_BWn	 <= MEMCNTRL_out_BWn;
			TOP_MEMCNTRL_out_Adv	 <= MEMCNTRL_out_Adv;
			TOP_MEMCNTRL_out_Mode	 <= MEMCNTRL_out_Mode;
			TOP_MEMCNTRL_out_OEn	 <= MEMCNTRL_out_OEn;
			TOP_MEMCNTRL_out_WEn	 <= MEMCNTRL_out_WEn;
			TOP_MEMCNTRL_out_CEn	 <= MEMCNTRL_out_CEn;
			
			
			TOP_out_SRAMDATA 	<= MEMCNTRL_out_DATAR(6 downto 0);			
			temp_memcntrl_datar <= MEMCNTRL_out_DATAR(sram_M-1 downto 0);
			
---------------------------------------------------------
-- CCHIPSCOPE RELATED MAPPING
---------------------------------------------------------
--	-- assigning the triggers
	ila_trigger0 <= ML_SRAMMC_out_WRITE & ML_SRAMMC_out_REQ;

	-- assigning the data observers
	ila_datain(511 downto 494) 	<= ML_SRAMMC_out_ADDR;
	ila_datain(493 downto 458) 	<= ML_SRAMMC_out_DATAW;
	ila_datain(457) 			<= ML_SRAMMC_out_WRITE;
	ila_datain(456) 			<= ML_SRAMMC_out_REQ;
	ila_datain(455) 			<= MEMCNTRL_out_FINISHED;
	ila_datain(454 downto 419) 	<= (others => '0');
	--ila_datain(454 downto 419) <= temp_memcntrl_datar;
	ila_datain(418) 			<= MEMCNTRL_out_CLK;
	ila_datain(417 downto 400) 	<= MEMCNTRL_out_ADDRM;			
	ila_datain(399 downto 364) 	<= TOP_MEMCNTRL_out_DATAM;
	ila_datain(363) 			<= MEMCNTRL_out_OEn;
	ila_datain(362) 			<= MEMCNTRL_out_WEn;
	ila_datain(361) 			<= MEMCNTRL_out_CEn;
	ila_datain(360) 			<= '0';
	ila_datain(359) 			<= TOP_in_BTN_RST;
	ila_datain(358 downto 356) 	<= MEMCNTRL_out_CURSTATE;
	ila_datain(355 downto 0) 	<= (others => '0');

	
	-- ILA module
	i_debug: debug
	  port map(
		CLK 	=> TOP_in_CLK,
		CONTROL => icon_control0,
		TRIG0 	=> ila_trigger0,
		DATA  	=> ila_datain
	  );

	-- ICON module 
	i_scope: scope
	  port map(
		CONTROL0 => icon_control0
	  );
		
			
end behavioral;

