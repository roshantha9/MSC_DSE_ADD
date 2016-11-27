----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467
-- 
-- Create Date:     18:08:40 02/25/2011 
-- Design Name:     BIST
-- Module Name:     BIST - Behavioral 
-- Project Name:    Lab5a
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     Built in Self-Test Unit, uses ROMs to store the test patterns 
--					the respective outputs, when a mismatch occurs, the COMPARE 
--					signal is made high, and the testing stops. A counter is used
--					to cycle through the ROM contents
--
-- Dependencies:    modn_counter, BIST_Control, romTP, romOUT
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
entity BIST is
		generic ( ram_size 			: natural := 4;		-- addr length
				  num_test_inputs 	: natural := 6;		
			      num_tests	   		: natural := 5);
		Port ( 	CLK 			: in  STD_LOGIC;
				B_RST 			: in  STD_LOGIC;
				B_TEST 			: in  STD_LOGIC;
				UUT_OUT 		: in  STD_LOGIC;
				TEST 			: out  STD_LOGIC_VECTOR (5 downto 0);
				MODE 			: out  STD_LOGIC;
				L_ERR 			: out  STD_LOGIC;
				L_ID 			: out  STD_LOGIC_VECTOR (3 downto 0));
end BIST;

architecture Behavioral of BIST is

----------------------------------------------------------------------------------
-- BIST Control Unit : Essentially a State Machine
----------------------------------------------------------------------------------
	
	component BIST_Control
	port ( 	CNTRL_in_CLK 			: in STD_LOGIC;  -- clock
			CNTRL_in_RST 			: in STD_LOGIC;	 -- reset
			 
			CNTRL_in_TEST 			: in STD_LOGIC;	 -- test button pressed
			CNTRL_in_COMPARE 		: in STD_LOGIC;  -- comparison is true/false
			CNTRL_in_CNTMAX			: in STD_LOGIC;  -- counter max value reached
			 
			CNTRL_out_CNT_EN		: out STD_LOGIC; -- counter enable
			CNTRL_out_MODE			: out STD_LOGIC; -- mode of the UUT =1(test)
			 
			CNTRL_out_REPORT_ERR 	: out STD_LOGIC; -- error detected notify
			CNTRL_out_FINISHED	 	: out STD_LOGIC  -- finished testing
		  );			 
	end component;

----------------------------------------------------------------------------------
-- Counter which is used to keep track of the rom addresses
----------------------------------------------------------------------------------
	component modn_counter
		generic( n 			: NATURAL := num_tests;	-- mod-n
				 bit_width 	: NATURAL := ram_size 	-- size of the count output
				);
		port(	CLK, RESET 	: in STD_LOGIC;			-- clock, reset
				EN 		  	: in STD_LOGIC;			-- count enable
				-- current register value
				COUNT 	  	: out STD_LOGIC_VECTOR(ram_size-1 downto 0); 
				-- max val reached flag	
				MAX_FLAG   	: out STD_LOGIC				
		);
	end component;
	
----------------------------------------------------------------------------------
-- ROM which will contain the test patterns
----------------------------------------------------------------------------------	
	component romTP
		port (
			a		: in STD_LOGIC_VECTOR(3 downto 0);
			spo	: out STD_LOGIC_VECTOR(5 downto 0));
	end component;

----------------------------------------------------------------------------------
-- ROM which will contain the test patterns outputs
----------------------------------------------------------------------------------		
	component romOUT
		port (
			a		: in STD_LOGIC_VECTOR(3 downto 0);
			spo		: out STD_LOGIC_VECTOR(0 downto 0));
	end component;
	
----------------------------------------------------------------------------------
-- Temporary signals used for wiring
----------------------------------------------------------------------------------
signal cntrl_out_mode 			: STD_LOGIC;
signal cntrl_out_cnt_en 		: STD_LOGIC; 
signal cntrl_out_report_err		: STD_LOGIC;
signal cntrl_out_finished		: STD_LOGIC;
signal ram_rd_addr			    : STD_LOGIC_VECTOR(ram_size-1 downto 0);
signal rom_tp_dout				: STD_LOGIC_VECTOR(num_test_inputs-1 downto 0);
signal rom_to_dout				: STD_LOGIC_VECTOR(0 downto 0);
signal count_max_flag 			: STD_LOGIC;
signal test_result_comp 		: STD_LOGIC;
signal uut_out_vector 			: STD_LOGIC_VECTOR(0 downto 0);

begin

	
----------------------------------------------------------------------------------
-- BIST Control unit instantiation : FSM
----------------------------------------------------------------------------------		
	Inst_BIST_Control : BIST_Control 
		port map ( 
			 CNTRL_in_CLK  		 	=> CLK,
			 CNTRL_in_RST  		 	=> B_RST,
			  
			 CNTRL_in_TEST 		 	=> B_TEST,
			 CNTRL_in_COMPARE 	 	=> test_result_comp,
			 CNTRL_in_CNTMAX	 	=> count_max_flag,
			 
			 CNTRL_out_CNT_EN	 	=> cntrl_out_cnt_en,
			 CNTRL_out_MODE		 	=> cntrl_out_mode,
			 
			 CNTRL_out_REPORT_ERR 	=> cntrl_out_report_err,
			 CNTRL_out_FINISHED	 	=> cntrl_out_finished	 
		  );
	
	MODE <= cntrl_out_mode;

----------------------------------------------------------------------------------
-- Counter Instantiation : used to track the rom addresses
----------------------------------------------------------------------------------	
	Inst_modn_counter : modn_counter	
		generic map( 	n => num_tests,		-- mod-n
						bit_width =>  ram_size 	-- size of the count output
				   )
		port map(	
					CLK 		=> CLK,
					RESET 		=> B_RST,
					EN 			=> cntrl_out_cnt_en,
					COUNT 		=> ram_rd_addr,
					MAX_FLAG 	=> count_max_flag
				);		
----------------------------------------------------------------------------------
-- romTP in instantiation used to hold the test patterns
----------------------------------------------------------------------------------
	Inst_romTP : romTP
		port map(
				a 	 => ram_rd_addr,
				spo  => rom_tp_dout
			);
	
	-- send out test patterns: from rom to top level
	TEST <= rom_tp_dout;
	
----------------------------------------------------------------------------------
-- romTP in instantiation used to hold the test pattern outputs
----------------------------------------------------------------------------------		
	Inst_romOUT : romOUT
		port map(
				a 	 => ram_rd_addr,
				spo  => rom_to_dout
			);	
----------------------------------------------------------------------------------
-- Comparison is true only when ram_out_data is not equal to uut_output
----------------------------------------------------------------------------------		
	test_result_comp <= '1' when ((rom_to_dout /= uut_out_vector) and cntrl_out_mode='1')  else '0';
	
	uut_out_vector(0) <=  UUT_OUT;

----------------------------------------------------------------------------------
-- Error notification, show the error id as well (ROM address)
----------------------------------------------------------------------------------	
	L_ERR <= test_result_comp;	
	L_ID  <= ram_rd_addr when (test_result_comp='1') else (others => '0');

end Behavioral;

