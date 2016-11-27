----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     22:50:06 02/07/2011 
-- Design Name:     Main Logic Unit
-- Module Name:     main_logic - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     connects up the mat_mul_controller and the mat_mul unit and 
--					the two debounce logic units
--					(basic wiring up)--
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
entity main_logic is
		generic ( 
					-- matrix sizes
					m 					: natural := 3;
					x 					: natural := 4;
					y 					: natural := 5;							 
					-- ram sizes
					ram_addr_size 		: natural := 4;
					ram_data_width 		: natural := 8;
					ram_c_addr_size 	: natural := 8;
					ram_c_data_width 	: natural := 48;					 
					--sram sizes
					sram_N 				: natural := 18;
					sram_M 				: natural := 36;					 
					-- macc unit sizes
					macc_data_size_a 	: natural := 18;
					macc_data_size_b 	: natural := 18;
					macc_data_size_c 	: natural := 48;
					macc_data_size_p 	: natural := 48;
					 
					-- truncated result size
					result_width 		: natural := 7					 
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
end main_logic;

architecture behavioral of main_logic is

----------------------------------------------------------------------------------
-- Component Declaration : mat_mul (Matrix Multiplication)
----------------------------------------------------------------------------------
	 component mat_mul
	 generic ( 
				-- matrix sizes
				m 						: natural := m;
				x 						: natural := x;
				y 						: natural := y;
				-- ram sizes
				ram_addr_size 			: natural := ram_addr_size;
				ram_data_width 			: natural := ram_data_width;			 
				ram_c_addr_size 		: natural := ram_c_addr_size;			 
				ram_c_data_width 		: natural := ram_c_data_width;				 
				ram_c_real_addr_size  	: natural := sram_N;
				ram_c_real_data_width 	: natural := sram_M
				-- macc unit size
				macc_data_size_a 		: natural := macc_data_size_a;
				macc_data_size_b 		: natural := macc_data_size_b;
				macc_data_size_c 		: natural := macc_data_size_c;
				macc_data_size_p 		: natural := macc_data_size_p;
				-- truncated result width
				result_width 			: natural := result_width;						
			  );				 
    port(
			CLK 				: in STD_LOGIC;
			RESET 				: in STD_LOGIC;
			
			-- control inputs
			CNTAm_EN 			: in STD_LOGIC;
			CNTAm_RST 			: in STD_LOGIC;			
			CNTAx_RST 			: in STD_LOGIC;		
			CNTBy_RST 			: in STD_LOGIC;			
			CNT_RCADR_INC 		: in STD_LOGIC;			
			MACC_EN				: in STD_LOGIC;
			MACC_RST 			: in STD_LOGIC;			
			RAMC_WR_EN 			: in STD_LOGIC_VECTOR(0 downto 0);		
			PROD_REG_EN 		: in STD_LOGIC;
			
			-- sram related inputs(given in from controller)
			MATMUL_SRAM_RDWR_FLAG 	: in STD_LOGIC;
			MATMUL_SRAM_RDP_INC		: in STD_LOGIC;		
			
			-- sram related outputs(given to the mem_controller/fsm)
			MATMUL_SRAM_RDWR_ADDR	: out STD_LOGIC_VECTOR(sram_N-1 downto 0);
			MATMUL_SRAM_DATAW		: out STD_LOGIC_VECTOR(sram_M-1 downto 0);
		    MATMUL_SRAM_READ_MAX 	: out STD_LOGIC;	
				
			-- multiplication algorithm related outputs
			PRD_COEF 		: out STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);
			PRD_COEF_TRUNC 	: out STD_LOGIC_VECTOR(result_width-1 downto 0);
			CNT_Am_DONE 	: out STD_LOGIC;
			CALC_COMPLETE 	: out STD_LOGIC
        );
    end component;
    
----------------------------------------------------------------------------------
-- Component Declaration : mat_mul_controller (Matrix Multiplication Controller)
----------------------------------------------------------------------------------	 
	component mat_mul_controller
	port(			
			CLK 					: in STD_LOGIC;
				
			-- external inputs 
			FSM_in_RESET 			: in STD_LOGIC;
			FSM_in_CALC  			: in STD_LOGIC;
			FSM_in_DISPLAY 			: in STD_LOGIC;
			
			-- internal inputs
			FSM_in_CNT_Ax_DONE 		: in STD_LOGIC;
			FSM_in_CALC_COMPLETE 	: in STD_LOGIC;
			
			--- from sram controller
			FSM_in_SRAM_FINISHED	: in STD_LOGIC;
			
			-- control outputs
			FSM_out_CNTAm_EN  		: out STD_LOGIC;
			FSM_out_CNTAm_RST 		: out STD_LOGIC;			
			FSM_out_CNTAx_RST 		: out STD_LOGIC;		
			FSM_out_CNTBy_RST 		: out STD_LOGIC;				
			FSM_out_CNT_RCADR_INC 	: out STD_LOGIC;			
			FSM_out_RAMC_WR_EN		: out STD_LOGIC_VECTOR(0 downto 0);			
			FSM_out_MACC_EN 		: out STD_LOGIC;
			FSM_out_MACC_RST 		: out STD_LOGIC;			
			FSM_out_PROD_REG_EN 	: out STD_LOGIC;			
			
			--- controls to sram controller
			FSM_out_SRAM_REQ	 	: out STD_LOGIC;
			FSM_out_SRAM_WRITE 		: out STD_LOGIC;
			FSM_out_SRAM_RDWR_FLAG 	: out STD_LOGIC; -- 1=wr, 0=rd
			FSM_out_SRAM_RDP_INC 	: out STD_LOGIC
			
		);
	end component;
	
----------------------------------------------------------------------------------
-- Component Declaration : debounce logic unit
----------------------------------------------------------------------------------		 
	 component debounce
	 Port ( D_IN  	: in STD_LOGIC;
			CLOCK 	: in  STD_LOGIC;
			RESET	: in  STD_LOGIC;
			Q_OUT 	: out  STD_LOGIC );	 
	 end component;

----------------------------------------------------------------------------------
-- Temporary signals used for wiring up.
----------------------------------------------------------------------------------

 	-- data path Outputs
	signal PRD_COEF_SIG 		 : std_logic_vector(macc_data_size_p-1 downto 0);
	signal PRD_COEF_TRUNC_SIG 	 : STD_LOGIC_VECTOR(result_width-1 downto 0);
	signal CNT_Am_DONE_SIG 		 : std_logic;
	signal CALC_COMPLETE_SIG 	 : std_logic;
	
	-- fsm outputs
	signal FSM_out_CNTAm_EN_SIG  		: STD_LOGIC;
	signal FSM_out_CNTAm_RST_SIG 		: STD_LOGIC;	 
	signal FSM_out_CNTAx_RST_SIG 		: STD_LOGIC;
	signal FSM_out_CNTBy_RST_SIG 		: STD_LOGIC;	
	signal FSM_out_CNT_RCADR_INC_SIG 	: STD_LOGIC;	
	signal FSM_out_RAMC_WR_EN_SIG 		: STD_LOGIC_VECTOR(0 downto 0);	
	signal FSM_out_MACC_EN_SIG 			: STD_LOGIC;
	signal FSM_out_MACC_RST_SIG 		: STD_LOGIC;
	
	signal FSM_out_PROD_REG_EN_SIG 		: STD_LOGIC;
	-- sram related fsm outputs
	signal FSM_out_SRAM_REQ_SIG	 		: STD_LOGIC;
	signal FSM_out_SRAM_WRITE_SIG 		: STD_LOGIC;
	signal FSM_out_SRAM_RDWR_FLAG_SIG 	: STD_LOGIC; -- 1=wr, 0=rd
	signal FSM_out_SRAM_RDP_INC_SIG 	: STD_LOGIC;

	-- debounce outputs
	signal DEB_Q_CALC_SIG 				: STD_LOGIC;
	signal DEB_Q_DISP_SIG 				: STD_LOGIC;
	
	-- signals to the sram controller, sent by mat_mul unit
	signal MATMUL_SRAM_RDWR_ADDR_SIG	: STD_LOGIC_VECTOR(sram_N-1 downto 0);
	signal MATMUL_SRAM_DATAW_SIG		: STD_LOGIC_VECTOR(sram_M-1 downto 0);
	signal MATMUL_SRAM_READ_MAX_SIG 	: STD_LOGIC;

begin
----------------------------------------------------------------------------------
-- Component Instantiation : mat_mul
----------------------------------------------------------------------------------
			i_mat_mul: mat_mul
			generic map( 
					 -- matrix sizes
					 m 						=> m,
					 x 						=> x,
					 y 						=> y,				 
					 -- ram sizes
					 ram_addr_size 			=> ram_addr_size,
					 ram_data_width 		=> ram_data_width,			 
					 ram_c_addr_size 		=> ram_c_addr_size,			 
					 ram_c_data_width 		=> ram_c_data_width,
					 ram_c_real_addr_size   => sram_N,
					 ram_c_real_data_width  => sram_M				 
					 -- macc unit sizes
					 macc_data_size_a 		=> macc_data_size_a,
					 macc_data_size_b 		=> macc_data_size_b,
					 macc_data_size_c 		=> macc_data_size_c,
					 macc_data_size_p 		=> macc_data_size_p,
					 -- truncated result size
					 result_width 			=> result_width,				 				 
				)
			port map (
				 CLK 					=> CLK,
				 RESET 					=> ML_in_BTN_RESET,
				 
				 -- inputs
				 CNTAm_EN 				=> FSM_out_CNTAm_EN_SIG,
				 CNTAm_RST 				=> FSM_out_CNTAm_RST_SIG,
				 CNTAx_RST 				=> FSM_out_CNTAx_RST_SIG,
				 CNTBy_RST 				=> FSM_out_CNTBy_RST_SIG,
				 CNT_RCADR_INC 			=> FSM_out_CNT_RCADR_INC_SIG,
				 MACC_EN 				=> FSM_out_MACC_EN_SIG,
				 MACC_RST 	   			=> FSM_out_MACC_RST_SIG,				 
				 RAMC_WR_EN  			=> FSM_out_RAMC_WR_EN_SIG,				 
				 PROD_REG_EN 			=> FSM_out_PROD_REG_EN_SIG,				 
				 
				 -- outputs
				 PRD_COEF 		 		=> PRD_COEF_SIG,
				 PRD_COEF_TRUNC 		=> PRD_COEF_TRUNC_SIG,
				 CNT_Am_DONE 	 		=> CNT_Am_DONE_SIG,
				 CALC_COMPLETE  		=> CALC_COMPLETE_SIG,
				 			
				 -- sram related inputs(given in from controller)
				 MATMUL_SRAM_RDWR_FLAG  => FSM_out_SRAM_RDWR_FLAG_SIG,
				 MATMUL_SRAM_DATAW		=> MATMUL_SRAM_DATAW_SIG,
				 MATMUL_SRAM_RDP_INC	=> FSM_out_SRAM_RDP_INC_SIG,
				
				 -- sram related outputs(given to the mem_controller/fsm)
				 MATMUL_SRAM_RDWR_ADDR  => MATMUL_SRAM_RDWR_ADDR_SIG,
				 MATMUL_SRAM_READ_MAX 	=> MATMUL_SRAM_READ_MAX_SIG			 
          );
			 
			 ML_out_PRD_COEF_TRUNC  <= PRD_COEF_TRUNC_SIG;
			 ML_out_CALC_COMPLETE   <= CALC_COMPLETE_SIG;			 
			
			 ML_SRAMMC_out_ADDR  	<= MATMUL_SRAM_RDWR_ADDR_SIG;
			 ML_SRAMMC_out_DATAW 	<= MATMUL_SRAM_DATAW_SIG;
			 ML_SRAMMC_out_WRITE 	<= FSM_out_SRAM_WRITE_SIG;
			 ML_SRAMMC_out_REQ		<= FSM_out_SRAM_REQ_SIG;
			 
----------------------------------------------------------------------------------
-- Component Instantiation : mat_mul_controller (Matrix Multiplication Unit FSM)
----------------------------------------------------------------------------------			
			
			-- fsm component instantiation
			i_fsm: mat_mul_controller 
			port map(				
				
				CLK 					=> CLK,
							
				-- external inputs 
				FSM_in_RESET 			=> ML_in_BTN_RESET,
				FSM_in_CALC  			=> DEB_Q_CALC_SIG,
				FSM_in_DISPLAY 			=> DEB_Q_DISP_SIG,
				
				-- internal inputs
				FSM_in_CNT_Ax_DONE 		=> CNT_Am_DONE_SIG,
				FSM_in_CALC_COMPLETE 	=> CALC_COMPLETE_SIG,
				
				--- from sram controller
				FSM_in_SRAM_FINISHED 	=> ML_SRAMMC_in_FINISHED,
				
				-- control outputs
				FSM_out_CNTAm_EN  		=> FSM_out_CNTAm_EN_SIG,
				FSM_out_CNTAm_RST 		=> FSM_out_CNTAm_RST_SIG,				 
				FSM_out_CNTAx_RST 		=> FSM_out_CNTAx_RST_SIG,
				FSM_out_CNTBy_RST 		=> FSM_out_CNTBy_RST_SIG,				
				FSM_out_CNT_RCADR_INC 	=> FSM_out_CNT_RCADR_INC_SIG,				
				FSM_out_RAMC_WR_EN 		=> FSM_out_RAMC_WR_EN_SIG,				
				FSM_out_MACC_EN 		=> FSM_out_MACC_EN_SIG,
				FSM_out_MACC_RST 		=> FSM_out_MACC_RST_SIG,				
				FSM_out_PROD_REG_EN 	=> FSM_out_PROD_REG_EN_SIG,
						
				--- controls to sram controller
				FSM_out_SRAM_REQ	 	=> FSM_out_SRAM_REQ_SIG,
				FSM_out_SRAM_WRITE 	 	=> FSM_out_SRAM_WRITE_SIG,
				FSM_out_SRAM_RDWR_FLAG  => FSM_out_SRAM_RDWR_FLAG_SIG,
				FSM_out_SRAM_RDP_INC 	=> FSM_out_SRAM_RDP_INC_SIG
			
			);		
			
----------------------------------------------------------------------------------
-- Component Instantiation : Debounce Logic Units - for CALC, RESET
----------------------------------------------------------------------------------	
			i_deb_calc: debounce
			port map ( ML_in_BTN_CALC,  CLK,  ML_in_BTN_RESET,  DEB_Q_CALC_SIG	);
			
			i_deb_disp: debounce
			port map ( ML_in_BTN_DISP,  CLK,  ML_in_BTN_RESET,  DEB_Q_DISP_SIG 	);

end behavioral;

