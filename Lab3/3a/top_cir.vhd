----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     22:50:06 02/07/2011 
-- Design Name:     Top Level Circuit
-- Module Name:     top_cir - Behavioral 
-- Project Name:    Lab3a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     top level circuit to multiply 2 matrices together, and store
--					the result in a BRAM.
--					sizes: 
--					Matrix A : (x by m)
--					Matric B : (m by y)
--					Matric C : (x by y) (result)
--
-- Dependencies:    mat_mul, mat_mul_controller, debounce
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

entity top_cir is
		
		-- circuit generics, params
		generic ( 
					 -- matrix sizes
					 m 					: natural := 3;	
					 x 					: natural := 4;
					 y 					: natural := 5;
					 -- ram size
					 ram_addr_size 		: natural := 4;
					 ram_data_width 	: natural := 8;
					 ram_c_addr_size 	: natural := 5;
					 ram_c_data_width 	: natural := 48
					 -- macc unit size
					 macc_data_size_a 	: natural := 18;
					 macc_data_size_b 	: natural := 18;
					 macc_data_size_c 	: natural := 48;
					 macc_data_size_p 	: natural := 48;
					 -- result bus size (truncated)
					 result_width 		: natural := 7;					 
				  );
		port (
				CLK 				: in STD_LOGIC;
				
				-- button presses --
				BTN_RESET 			: in STD_LOGIC;
				BTN_CALC  			: in STD_LOGIC;
				
				-- outputs --
				OUT_PRD_COEF_TRUNC 	: out STD_LOGIC_VECTOR(result_width-1 downto 0);
				OUT_CALC_COMPLETE 	: out STD_LOGIC	
		);
end top_cir;

architecture behavioral of top_cir is

----------------------------------------------------------------------------------
-- Component Declaration : Matrix Multiplication Unit (mat_mul)
----------------------------------------------------------------------------------
	
	 component mat_mul
	 generic ( 
				 -- matrix sizes
				 m 					: natural := m;
				 x 					: natural := x;
				 y 					: natural := y;				 
				 -- ram size
				 ram_addr_size 		: natural := ram_addr_size;
				 ram_data_width 	: natural := ram_data_width;
				 ram_c_addr_size 	: natural := ram_c_addr_size;
				 ram_c_data_width 	: natural := ram_c_data_width
				 -- macc size
				 macc_data_size_a 	: natural := macc_data_size_a;
				 macc_data_size_b 	: natural := macc_data_size_b;
				 macc_data_size_c 	: natural := macc_data_size_c;
				 macc_data_size_p 	: natural := macc_data_size_p;
				 -- result bus size
				 result_width : natural := result_width;				 
			  );	 
    port(
			CLK 			: in STD_LOGIC;
			RESET 			: in STD_LOGIC;
			
			-- control inputs
			CNTAm_EN 		: in STD_LOGIC;
			CNTAm_RST 		: in STD_LOGIC;			
			CNTAx_RST 		: in STD_LOGIC;		
			CNTBy_RST 		: in STD_LOGIC;			
			CNT_RCADR_INC 	: in STD_LOGIC;			
			MACC_EN 		: in STD_LOGIC;
			MACC_RST 		: in STD_LOGIC;			
			RAMC_WR_EN 		: in STD_LOGIC_VECTOR(0 downto 0);			
			PROD_REG_EN 	: in STD_LOGIC;			
			
			-- outputs to top level cir
			PRD_COEF 		: out STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);
			PRD_COEF_TRUNC 	: out STD_LOGIC_VECTOR(result_width-1 downto 0);
			CNT_Am_DONE 	: out STD_LOGIC;
			CALC_COMPLETE 	: out STD_LOGIC		-- led display	
        );
    end component;
    
----------------------------------------------------------------------------------
-- Component Declaration : Matrix Multiplication Control Unit (mat_mul_controller)
----------------------------------------------------------------------------------	 
	 component mat_mul_controller
	 port(
			CLK 					: in STD_LOGIC;
			
			-- external inputs 
			FSM_in_RESET 			: in STD_LOGIC;
			FSM_in_CALC  			: in STD_LOGIC;
			
			-- internal inputs
			FSM_in_CNT_Am_DONE 		: in STD_LOGIC;
			FSM_in_CALC_COMPLETE 	: in STD_LOGIC;
			
			-- control outputs
			FSM_out_CNTAm_EN  		: out STD_LOGIC;
			FSM_out_CNTAm_RST 		: out STD_LOGIC;			
			FSM_out_CNTAx_RST 		: out STD_LOGIC;		
			FSM_out_CNTBy_RST 		: out STD_LOGIC;			
			FSM_out_CNT_RCADR_INC 	: out STD_LOGIC;			
			FSM_out_RAMC_WR_EN 		: out STD_LOGIC_VECTOR(0 downto 0);			
			FSM_out_MACC_EN 		: out STD_LOGIC;
			FSM_out_MACC_RST 		: out STD_LOGIC;			
			FSM_out_PROD_REG_EN 	: out STD_LOGIC
			
		);
	 end component;
	 
----------------------------------------------------------------------------------
-- Component Declaration : Debounce Unit
----------------------------------------------------------------------------------	 
	 component debounce
	 Port (   D_IN  : in STD_LOGIC;
			  CLOCK : in  STD_LOGIC;
			  RESET : in  STD_LOGIC;
			  Q_OUT : out  STD_LOGIC 
		  );	 
	 end component;

----------------------------------------------------------------------------------
-- Temporary signals used for wiring
----------------------------------------------------------------------------------
 	--data path Outputs
	signal PRD_COEF_SIG 			: std_logic_vector(47 downto 0);
	signal PRD_COEF_TRUNC_SIG 		: STD_LOGIC_VECTOR(result_width-1 downto 0);
	signal CNT_Am_DONE_SIG 			: std_logic;
	signal CALC_COMPLETE_SIG 		: std_logic;
	
	-- fsm outputs
	signal FSM_out_CNTAm_EN_SIG  	 : STD_LOGIC;
	signal FSM_out_CNTAm_RST_SIG 	 : STD_LOGIC;	 
	signal FSM_out_CNTAx_RST_SIG 	 : STD_LOGIC;
	signal FSM_out_CNTBy_RST_SIG 	 : STD_LOGIC;	
	signal FSM_out_CNT_RCADR_INC_SIG : STD_LOGIC;	
	signal FSM_out_RAMC_WR_EN_SIG 	 : STD_LOGIC_VECTOR(0 downto 0);	
	signal FSM_out_MACC_EN_SIG 		 : STD_LOGIC;
	signal FSM_out_MACC_RST_SIG 	 : STD_LOGIC;		
	signal DEB_Q_OUT_SIG 			 : STD_LOGIC;	
	signal FSM_out_PROD_REG_EN_SIG   : STD_LOGIC;



begin

----------------------------------------------------------------------------------
-- Component Instatiation : mat_mul unit
----------------------------------------------------------------------------------

		i_mat_mul: mat_mul
		generic map(
			 -- matrix sizes
			 m 					=> m,
			 x 					=> x,
			 y 					=> y,
			 -- ram sizes
			 ram_addr_size 		=> ram_addr_size,
			 ram_data_width 	=> ram_data_width,
			 ram_c_addr_size 	=> ram_c_addr_size,
			 ram_c_data_width 	=> ram_c_data_width
			 -- macc unit size
			 macc_data_size_a 	=> macc_data_size_a,
			 macc_data_size_b 	=> macc_data_size_b,
			 macc_data_size_c 	=> macc_data_size_c,
			 macc_data_size_p 	=> macc_data_size_p,
			 -- result bus size (truncated result)
			 result_width 		=> result_width,
			 
		  )
		port map (
			 CLK 			=> CLK,
			 RESET 			=> BTN_RESET,
			 
			 -- inputs
			 CNTAm_EN 		=> FSM_out_CNTAm_EN_SIG,
			 CNTAm_RST 		=> FSM_out_CNTAm_RST_SIG,
			 CNTAx_RST 		=> FSM_out_CNTAx_RST_SIG,
			 CNTBy_RST 		=> FSM_out_CNTBy_RST_SIG,
			 CNT_RCADR_INC 	=> FSM_out_CNT_RCADR_INC_SIG,
			 MACC_EN 		=> FSM_out_MACC_EN_SIG,
			 MACC_RST 		=> FSM_out_MACC_RST_SIG,			 
			 RAMC_WR_EN 	=> FSM_out_RAMC_WR_EN_SIG,			 
			 PROD_REG_EN 	=> FSM_out_PROD_REG_EN_SIG,
			 			 
			 -- outputs
			 PRD_COEF 		=> PRD_COEF_SIG,
			 PRD_COEF_TRUNC => PRD_COEF_TRUNC_SIG,
			 CNT_Am_DONE 	=> CNT_Am_DONE_SIG,
			 CALC_COMPLETE 	=> CALC_COMPLETE_SIG
	  );
		 
		 -- truncated output
		 OUT_PRD_COEF_TRUNC <= PRD_COEF_TRUNC_SIG;
		 -- calculation complete led notify
		 OUT_CALC_COMPLETE  <= CALC_COMPLETE_SIG;
		 
----------------------------------------------------------------------------------
-- Component Instatiation : mat_mul_controller unit (FSM)
----------------------------------------------------------------------------------
		-- fsm component instantiation
		i_fsm: mat_mul_controller 
		port map(				
			
			CLK 					=> CLK,
						
			-- external inputs 
			FSM_in_RESET 			=> BTN_RESET,
			FSM_in_CALC  			=> DEB_Q_OUT_SIG,
			
			-- internal inputs
			FSM_in_CNT_Am_DONE 		=> CNT_Am_DONE_SIG,
			FSM_in_CALC_COMPLETE 	=> CALC_COMPLETE_SIG,
			
			-- control outputs
			FSM_out_CNTAm_EN  		=> FSM_out_CNTAm_EN_SIG,
			FSM_out_CNTAm_RST 		=> FSM_out_CNTAm_RST_SIG,			 
			FSM_out_CNTAx_RST 		=> FSM_out_CNTAx_RST_SIG,
			FSM_out_CNTBy_RST 		=> FSM_out_CNTBy_RST_SIG,			
			FSM_out_CNT_RCADR_INC 	=> FSM_out_CNT_RCADR_INC_SIG,			
			FSM_out_RAMC_WR_EN 		=> FSM_out_RAMC_WR_EN_SIG,			
			FSM_out_MACC_EN 		=> FSM_out_MACC_EN_SIG,
			FSM_out_MACC_RST 		=> FSM_out_MACC_RST_SIG,			
			FSM_out_PROD_REG_EN 	=> FSM_out_PROD_REG_EN_SIG			
		);		  

----------------------------------------------------------------------------------
-- Component Instatiation : Debounce logic
----------------------------------------------------------------------------------
		i_deb: debounce
		port map
		(
		  D_IN  	=> BTN_CALC,
		  CLOCK 	=> CLK,
		  RESET 	=> BTN_RESET,
		  Q_OUT 	=> DEB_Q_OUT_SIG
		);

end behavioral;

