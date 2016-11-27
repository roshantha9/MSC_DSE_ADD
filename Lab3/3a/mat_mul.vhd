----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     16:00:02 02/05/2011 
-- Design Name:     Matrix Multiplication Unit
-- Module Name:     mat_mul - Behavioral 
-- Project Name:    Lab3a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     reads the matrix values from the BRAMs (A and B) and inputs 
--					them to the MACC unit, output of MACC unit (products)
--					are stored in the third BRAM (C). ModN Up counters are linked
--					together and used to keep track of the BRAM addresses.--					
--					intermadiate registers are used to hold read/write address
--					pointers.
--
-- Dependencies:    bram_A, bram_B, bram_C, macc, modn_counter
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

entity mat_mul is
	generic ( 	 
				 -- matrix sizes
				 m 					: natural := 3;
				 x 					: natural := 4;
				 y 					: natural := 5;				 
				 -- ram size
				 ram_addr_size 		: natural := 4;
				 ram_data_width 	: natural := 5;
				 ram_c_addr_size 	: natural := 8;
				 ram_c_data_width 	: natural := 48;
				 -- macc size
				 macc_data_size_a 	: natural := 18;
				 macc_data_size_b 	: natural := 18;
				 macc_data_size_c 	: natural := 48;
				 macc_data_size_p 	: natural := 48;
				 -- result bus size
				 result_width 		: natural := 7;
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
end mat_mul;

architecture behavioral of mat_mul is

----------------------------------------------------------------------------------
-- Component Declaration : bram_A
----------------------------------------------------------------------------------
	component bram_A
		port(
				clka	: IN std_logic;
				dina	: IN std_logic_VECTOR(ram_data_width-1 downto 0);
				addra	: IN std_logic_VECTOR(ram_addr_size-1 downto 0);
				wea		: IN std_logic_VECTOR(0 downto 0);
				clkb	: IN std_logic;
				addrb	: IN std_logic_VECTOR(ram_addr_size-1 downto 0);
				doutb	: OUT std_logic_VECTOR(ram_data_width-1 downto 0)
			);
	end component;

----------------------------------------------------------------------------------
-- Component Declaration : bram_B
----------------------------------------------------------------------------------	
	component bram_B
		port(
				clka	: IN std_logic;
				dina	: IN std_logic_VECTOR(ram_data_width-1 downto 0);
				addra	: IN std_logic_VECTOR(ram_addr_size-1 downto 0);
				wea		: IN std_logic_VECTOR(0 downto 0);
				clkb	: IN std_logic;
				addrb	: IN std_logic_VECTOR(ram_addr_size-1 downto 0);
				doutb	: OUT std_logic_VECTOR(ram_data_width-1 downto 0)
			);
	end component;

----------------------------------------------------------------------------------
-- Component Declaration : bram_C
----------------------------------------------------------------------------------
	component bram_C
		port(
				clka	: IN std_logic;
				dina	: IN std_logic_VECTOR(ram_c_data_width-1 downto 0);
				addra	: IN std_logic_VECTOR(ram_c_addr_size-1 downto 0);
				wea		: IN std_logic_VECTOR(0 downto 0);
				clkb	: IN std_logic;
				addrb	: IN std_logic_VECTOR(ram_c_addr_size-1 downto 0);
				doutb	: OUT std_logic_VECTOR(ram_c_data_width-1 downto 0)
			);
	end component;

----------------------------------------------------------------------------------
-- Component Declaration : modn_counter
----------------------------------------------------------------------------------
	component modn_counter
		generic( n 			: NATURAL;
				 bit_width 	: NATURAL
			   );
		port(	CLK, RESET 	: in STD_LOGIC;
				EN 		  	: in STD_LOGIC;		-- count enable
				COUNT 	  	: out STD_LOGIC_VECTOR(bit_width-1 downto 0); -- current register value
				MAX_FLAG   	: out STD_LOGIC    	-- max val reached flag					
			);			
	end component;

----------------------------------------------------------------------------------
-- Component Declaration : macc
----------------------------------------------------------------------------------	
	component macc
	port(
		A_IN 		: IN std_logic_vector(macc_data_size_a-1 downto 0);
		B_IN 		: IN std_logic_vector(macc_data_size_b-1 downto 0);
		CE_IN 		: IN std_logic;
		CLK_IN 		: IN std_logic;
		C_IN 		: IN std_logic_vector(macc_data_size_c-1 downto 0);
		RST_IN 		: IN std_logic;          
		P_OUT 		: OUT std_logic_vector(macc_data_size_p-1 downto 0)
		);
	end component;

----------------------------------------------------------------------------------
-- Temporary signals used to wire up and used for intermediate registers
----------------------------------------------------------------------------------	
		
	-- used for grounding various ports
	signal null_sig1 	: STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal null_sig2 	: STD_LOGIC_VECTOR(ram_data_width-1 downto 0);
	signal null_sig3 	: STD_LOGIC;
	signal null_sig4 	: STD_LOGIC_VECTOR(ram_c_addr_size-1 downto 0);
	signal null_sig5 	: STD_LOGIC_VECTOR(ram_c_data_width-1 downto 0);
   	
	-- A, B ram outputs
	signal bramA_dout 	: STD_LOGIC_VECTOR(ram_data_width-1 downto 0);
	signal bramB_dout 	: STD_LOGIC_VECTOR(ram_data_width-1 downto 0);
	
	-- counter related signals
	-- max flags
	signal count_a_m_maxflag : STD_LOGIC;
	signal count_a_x_maxflag : STD_LOGIC;
	signal count_b_y_maxflag : STD_LOGIC;
	signal count_addrC_maxflag : STD_LOGIC;	
	-- enable lines
	signal count_ax_en 	: STD_LOGIC;
	signal count_by_en 	: STD_LOGIC;		
	-- reset lines
	signal count_ax_rst : STD_LOGIC;
	signal count_am_rst : STD_LOGIC;
	signal count_by_rst : STD_LOGIC;	
	-- counter outputs
	signal count_Am_out : STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal count_Ax_out : STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal count_By_out : STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	
	-- ram addresses
	signal ramA_rd_addr 	: STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal ramB_rd_addr_tmp : STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal ramB_rd_addr 	: STD_LOGIC_VECTOR(ram_addr_size-1 downto 0);
	signal ramC_wr_addr 	: STD_LOGIC_VECTOR(ram_c_addr_size-1 downto 0);
	-- ram c input
	signal ramC_din 		: STD_LOGIC_VECTOR(ram_c_data_width-1 downto 0);
	
	-- macc unit related
	signal macc_input_a 	: STD_LOGIC_VECTOR(macc_data_size_a-1 downto 0);
	signal macc_input_b 	: STD_LOGIC_VECTOR(macc_data_size_b-1 downto 0);
	signal macc_input_c 	: STD_LOGIC_VECTOR(macc_data_size_c-1 downto 0);
	signal macc_output_p 	: STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);	
	signal macc_tmp_c 		: STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);
	
	-- macc unit input registers
	signal macc_in_reg_a	: STD_LOGIC_VECTOR(ram_data_width-1 downto 0);
	signal macc_in_reg_b 	: STD_LOGIC_VECTOR(ram_data_width-1 downto 0);
	signal macc_in_reg_p 	: STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);
		
	-- product co-efficient register
	signal prod_coef_reg 	: STD_LOGIC_VECTOR(macc_data_size_p-1 downto 0);
	
begin		
	 
	 null_sig1 <= (others => '0');
	 null_sig2 <= (others => '0');	 

----------------------------------------------------------------------------------
-- Component Instantiation: BRAMs (wiring up), A and B : read only, C : writable
----------------------------------------------------------------------------------
	 -- Block Ram - A
	 i_bram_A: bram_A
	 port map(	CLK,	null_sig2,	null_sig1,	"0",	CLK,	ramA_rd_addr,	bramA_dout );	 
	  
	 -- Block Ram - B
	 i_bram_B: bram_B
	 port map(	CLK, null_sig2, null_sig1,	"0", CLK, ramB_rd_addr,	bramB_dout	);		
	 
	 -- Block Ram - C
	 i_bram_C: bram_C
	 port map(	CLK, ramC_din, ramC_wr_addr, RAMC_WR_EN, '0', null_sig4, null_sig5  );		

----------------------------------------------------------------------------------
-- Component Instantiation:  BRAM_B, address register
----------------------------------------------------------------------------------	 

	 -- RAM addr B, start pointer increment
	 p_ramb_addr1: process is
	 begin
		wait until rising_edge(CLK);
		if(RESET='1' or CNTAm_RST='1') then
			ramB_rd_addr_tmp <= (others => '0');			
		elsif(count_by_en = '1') then
			ramB_rd_addr_tmp <= ramB_rd_addr_tmp + m;
		else
			ramB_rd_addr_tmp <= ramB_rd_addr_tmp;
		end if;		
	 end process;
	 
	 ramB_rd_addr <= ramB_rd_addr_tmp + count_Am_out;	 
		
----------------------------------------------------------------------------------
-- Component Instantiation:  MACC unit (Multiply Accumulate)
----------------------------------------------------------------------------------		
	 -- sign extension for the MACC inputs
	 macc_input_a(ram_data_width-1 downto 0) <= bramA_dout;
	 macc_input_a(macc_data_size_a-1 downto ram_data_width) <= (others => bramA_dout(ram_data_width-1));	 
 
	 macc_input_b(ram_data_width-1 downto 0) <= bramB_dout;
	 macc_input_b(macc_data_size_b-1 downto ram_data_width) <= (others => bramB_dout(ram_data_width-1));
	
	 -- multiply accumulate unit
	 i_macc: macc 
	 PORT MAP(
		A_IN => macc_input_a,
		B_IN =>  macc_input_b,
		CE_IN => MACC_EN,		
		CLK_IN => CLK,
		C_IN => macc_tmp_c,
		RST_IN => MACC_RST,
		P_OUT => macc_tmp_c 
	);
	
----------------------------------------------------------------------------------
-- Register to store the intermediate product co-efficient value
----------------------------------------------------------------------------------	
	 -- register to store the contents of the product-coefficient
	 p_prod_coeff: process is
	 begin
		wait until rising_edge(CLK);
		if(RESET='1') then
			prod_coef_reg <= (others => '0');			
		elsif(PROD_REG_EN = '1') then
			prod_coef_reg <= macc_tmp_c;
		else
			prod_coef_reg <= prod_coef_reg;
		end if;		
	 end process;	
		 	 
	 PRD_COEF <= prod_coef_reg;
	 -- truncated product coefficient (to display on LEDS)
	 PRD_COEF_TRUNC <= prod_coef_reg(result_width-1 downto 0);
	 -- input to BRAM_C
	 ramC_din <= prod_coef_reg;
	 
	 -- counter reset signals 
     count_ax_rst 	 <=   (RESET or CNTAx_RST);
	 count_am_rst	 <=   (RESET or CNTAm_RST); 
	 count_by_rst	 <=   (RESET or CNTBy_RST);

----------------------------------------------------------------------------------
-- Component Instantiation : ModN Up Counters
----------------------------------------------------------------------------------		 
	------------------------------------------------------------------------------
	-- CAm 		:  Used to keep track of the columns of the Matrix A. 
	--			   Enable line is triggered by the FSM output. Counts up to: m
	i_CAm: modn_counter 
	generic map( n => m, bit_width => ram_addr_size )
	port map( CLK, count_am_rst, CNTAm_EN, count_Am_out, count_a_m_maxflag	);	
	
	CNT_Am_DONE <= count_a_m_maxflag;
	------------------------------------------------------------------------------
	-- CAx 		:  Used to keep track of the number of rows in Matric A. 
	--			   Enable line is triggered by FSM output and CAm max flag. 
	--			   Counts up to: x
	count_ax_en <= count_a_m_maxflag and CNTAm_EN;
	 
	i_CAx: modn_counter 
	generic map( n => x, bit_width => ram_addr_size )
	port map( CLK, count_ax_rst, count_ax_en, count_Ax_out, count_a_x_maxflag );	
	
	------------------------------------------------------------------------------
	-- CBy 		:  Used to keep track of the columns of Matrix B. Counts up to: y
	count_by_en <= count_a_x_maxflag and count_a_m_maxflag;
	 
	i_CBy: modn_counter 
	generic map( n => y, bit_width => ram_addr_size )
	port map( CLK, count_by_rst, count_by_en, count_By_out, count_b_y_maxflag );		 
	
	------------------------------------------------------------------------------
	-- C_AddrA 	:  This counters COUNT output will be connected to the BRAM_A 
	--			   read address pointer. Counts up to: m*x	 
	 
	i_C_AddrA: modn_counter 
	generic map( n => (m*x), bit_width => ram_addr_size )
	port map( CLK, RESET, CNTAm_EN, ramA_rd_addr, null_sig3 );
	
	------------------------------------------------------------------------------
	-- C_AddrA	:  This counters COUNT output will be connected to the BRAM_C 
	--			   write address pointer. Counts up to: (x*y)-1	 
	i_C_AddrC: modn_counter 
	generic map( n => ((x*y)+1), bit_width => ram_c_addr_size )
	port map( CLK, RESET, CNT_RCADR_INC , ramC_wr_addr, count_addrC_maxflag );	 
	
	------------------------------------------------------------------------------
	-- matrix multiplication complete signal
	CALC_COMPLETE <= count_addrC_maxflag;
	 

end behavioral;

