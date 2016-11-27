----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     22:23:37 02/14/2011 
-- Design Name:     Top Level Circuit - Test Bench
-- Module Name:     toplevel_tb.vhd - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     The top level circuit Test bench. similar to the one in 
--					Task A. the CALC signal would go high for 5 clock cycles, 
--					then the test bench would ‘wait’ until the COMPLETE signal 
--					is high (signalling matrix calculation is complete, and 
--					values are stored on the SRAM), then start toggling the DISPLAY
--					signal (which will read the SRAM and display the read values on
--					the leds)
--
-- Dependencies:    toplevel
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY toplevel_tb IS
end toplevel_tb;
 
ARCHITECTURE behavior OF toplevel_tb IS 

----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------

	 constant clk_period 			: time := 10ns; 
	 constant m : natural 			:= 3;
	 constant x : natural 			:= 4;
	 constant y : natural 			:= 5;				 
	 constant ram_addr_size 		: natural := 4;
	 constant ram_data_width 		: natural := 8;
	 constant macc_data_size_a 		: natural := 18;
	 constant macc_data_size_b 		: natural := 18;
     constant macc_data_size_c 		: natural := 48;
	 constant macc_data_size_p 		: natural := 48;
     constant result_width 			: natural := 7;
	 constant ram_c_addr_size 		: natural := 8;
	 constant ram_c_data_width 		: natural := 48;
	 constant sram_N 				: natural := 9;
	 constant sram_M 				: natural := 36;
	 
----------------------------------------------------------------------------------
-- Component Declaration: Top Level Circuit
----------------------------------------------------------------------------------	
	
    -- component Declaration for the Unit Under Test (UUT) 
    component toplevel
	 generic(
				-- matrix size
				m 					: natural := m;
				x 					: natural := x;
				y 					: natural := y;				
				-- ram size
				ram_c_addr_size 	: natural := ram_c_addr_size;
				ram_c_data_width 	: natural := ram_c_data_width;
				sram_N 				: natural := sram_N;
				sram_M 				: natural := sram_M				
				ram_addr_size 		: natural := ram_addr_size;
				ram_data_width 		: natural := ram_data_width;				
				-- macc size
				macc_data_size_a 	: natural := macc_data_size_a;
				macc_data_size_b 	: natural := macc_data_size_b;
				macc_data_size_c 	: natural := macc_data_size_c;
				macc_data_size_p 	: natural := macc_data_size_p;
				-- truncated result width
				result_width 		: natural := result_width;
				
			);   
    port(
         TOP_in_CLK 			: in  STD_LOGIC;
		 -- button inputs
         TOP_in_BTN_CALC 		: in  STD_LOGIC;
         TOP_in_BTN_RST 		: in  STD_LOGIC;
         TOP_in_BTN_DISP 		: in  STD_LOGIC;
		 -- outputs to led
         TOP_out_COMPLETE 		: out  STD_LOGIC;
         TOP_out_SRAMDATA 		: out  STD_LOGIC_VECTOR(6 downto 0);
		 -- outputs to sram controller
         TOP_MEMCNTRL_out_CLK 	: out  STD_LOGIC;
         TOP_MEMCNTRL_out_ADDRM : out  STD_LOGIC_VECTOR(sram_N-1 downto 0);
         TOP_MEMCNTRL_out_DATAM : inout  STD_LOGIC_VECTOR(sram_M-1 downto 0);
         TOP_MEMCNTRL_out_BWn 	: out  STD_LOGIC_VECTOR(3 downto 0);
         TOP_MEMCNTRL_out_Adv 	: out  STD_LOGIC;
         TOP_MEMCNTRL_out_Mode 	: out  STD_LOGIC;
         TOP_MEMCNTRL_out_OEn 	: out  STD_LOGIC;
         TOP_MEMCNTRL_out_WEn 	: out  STD_LOGIC;
         TOP_MEMCNTRL_out_CEn 	: out  STD_LOGIC
        );
    end component;

----------------------------------------------------------------------------------
-- Component Declaration: SRAM Model
----------------------------------------------------------------------------------	
	 
	 component SRAM
	 generic ( word_len : NATURAL := sram_M;	-- word size
			   adr_size : NATURAL := sram_N		-- address size
			  );
	 port (
			SRAM_CLK	: in STD_LOGIC;		-- clock
			SRAM_ADDR_M : in  STD_LOGIC_VECTOR(sram_N-1 downto 0);	-- r/w address
			SRAM_DATA_M : inout STD_LOGIC_VECTOR(sram_M-1 downto 0); -- data io bus
			SRAM_CEn 	: in STD_LOGIC;	-- chip enable
			SRAM_OEn 	: in STD_LOGIC;	-- output enable
			SRAM_WEn 	: in STD_LOGIC    -- write enable
		 );
	 end component;
	 
----------------------------------------------------------------------------------
-- Temporary signals used for wiring up
----------------------------------------------------------------------------------	
   --inputs
   signal TOP_in_CLK_TB 		: STD_LOGIC := '0';
   signal TOP_in_BTN_CALC_TB 	: STD_LOGIC := '0';
   signal TOP_in_BTN_RST_TB 	: STD_LOGIC := '0';
   signal TOP_in_BTN_DISP_TB 	: STD_LOGIC := '0';
   signal TOP_out_COMPLETE_TB 	: STD_LOGIC := '0';
   signal TOP_out_SRAMDATA_TB 	: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');

	--BiDirs
   signal TOP_MEMCNTRL_out_DATAM_TB : STD_LOGIC_VECTOR(sram_M-1 downto 0);

 	--outputs
   signal TOP_MEMCNTRL_out_CLK_TB 	: STD_LOGIC;
   signal TOP_MEMCNTRL_out_ADDRM_TB : STD_LOGIC_VECTOR(sram_N-1 downto 0);
   signal TOP_MEMCNTRL_out_BWn_TB 	: STD_LOGIC_VECTOR(3 downto 0);
   signal TOP_MEMCNTRL_out_Adv_TB 	: STD_LOGIC;
   signal TOP_MEMCNTRL_out_Mode_TB 	: STD_LOGIC;
   signal TOP_MEMCNTRL_out_OEn_TB 	: STD_LOGIC;
   signal TOP_MEMCNTRL_out_WEn_TB 	: STD_LOGIC;
   signal TOP_MEMCNTRL_out_CEn_TB 	: STD_LOGIC;
	
   signal tmp_start_disp_flag		: STD_LOGIC := '0';
 
begin

----------------------------------------------------------------------------------
-- instantiate the Unit Under Test (UUT) - toplevel
----------------------------------------------------------------------------------	
	
   uut: toplevel 		
		generic map(
					-- matrix size
					m 					=> m,
					x 					=> x,
					y 					=> y,
					-- ram size
					ram_addr_size  		=> ram_addr_size,
					ram_data_width 		=> ram_data_width,
					ram_c_addr_size 	=> ram_c_addr_size,
					ram_c_data_width 	=> ram_c_data_width,
					sram_N 				=> sram_N,
					sram_M 				=> sram_M,
					-- macc size
					macc_data_size_a 	=> macc_data_size_a,
					macc_data_size_b 	=> macc_data_size_b,
					macc_data_size_c 	=> macc_data_size_c,
					macc_data_size_p 	=> macc_data_size_p,
					-- truncated result width
					result_width 		=> result_width				
			)  
		port map (
          TOP_in_CLK 				=> TOP_in_CLK_TB,
          -- button inputs
		  TOP_in_BTN_CALC			=> TOP_in_BTN_CALC_TB,
          TOP_in_BTN_RST 			=> TOP_in_BTN_RST_TB,
          TOP_in_BTN_DISP 			=> TOP_in_BTN_DISP_TB,
          -- outputs to leds
		  TOP_out_COMPLETE 			=> TOP_out_COMPLETE_TB,
          TOP_out_SRAMDATA 			=> TOP_out_SRAMDATA_TB,
          -- memory controller outputs
		  TOP_MEMCNTRL_out_CLK 		=> TOP_MEMCNTRL_out_CLK_TB,
          TOP_MEMCNTRL_out_ADDRM 	=> TOP_MEMCNTRL_out_ADDRM_TB,
          TOP_MEMCNTRL_out_DATAM 	=> TOP_MEMCNTRL_out_DATAM_TB,
          TOP_MEMCNTRL_out_BWn 		=> TOP_MEMCNTRL_out_BWn_TB,
          TOP_MEMCNTRL_out_Adv 		=> TOP_MEMCNTRL_out_Adv_TB,
          TOP_MEMCNTRL_out_Mode 	=> TOP_MEMCNTRL_out_Mode_TB,
          TOP_MEMCNTRL_out_OEn 		=> TOP_MEMCNTRL_out_OEn_TB,
          TOP_MEMCNTRL_out_WEn 		=> TOP_MEMCNTRL_out_WEn_TB,
          TOP_MEMCNTRL_out_CEn 		=> TOP_MEMCNTRL_out_CEn_TB
        );
		
----------------------------------------------------------------------------------
-- instantiate the Unit Under Test2 (UUT) - SRAM model
----------------------------------------------------------------------------------	
   uut2: sram 	
	 generic map ( word_len => sram_M,	-- word size
				   adr_size => sram_N	-- address size
				 )
	 port map(
			SRAM_CLK		=> TOP_MEMCNTRL_out_CLK_TB,   -- clock
			SRAM_ADDR_M 	=> TOP_MEMCNTRL_out_ADDRM_TB, -- r/w address
			SRAM_DATA_M 	=> TOP_MEMCNTRL_out_DATAM_TB, -- data io bus
			SRAM_CEn 		=> TOP_MEMCNTRL_out_CEn_TB,   -- chip enable
			SRAM_OEn 		=> TOP_MEMCNTRL_out_OEn_TB,   -- output enable
			SRAM_WEn 		=> TOP_MEMCNTRL_out_WEn_TB    -- write enable
		 );
	
----------------------------------------------------------------------------------
-- Clock Generation (clock process)
----------------------------------------------------------------------------------	
   clk_process :process
   begin
		TOP_in_CLK_TB <= '0';
		wait for clk_period/2;
		TOP_in_CLK_TB <= '1';
		wait for clk_period/2;
   end process;

----------------------------------------------------------------------------------
-- Read process - DISPLAY button is toggled
----------------------------------------------------------------------------------	   

	-- On User press (Calc=1), read SRAM and
	-- display result
	stim_proc_read: process
	begin
		
		-- wait till calculation is finished
		wait until (tmp_start_disp_flag = '1');
		
		-- continue pressing the button - forever
		while(tmp_start_disp_flag='1') loop
		
			wait for clk_period*10;
			TOP_in_BTN_DISP_TB <= '1';
			wait for clk_period*5;
			TOP_in_BTN_DISP_TB <= '0';
			
		end loop;
		
	end process;

----------------------------------------------------------------------------------
-- Write Process: CALC is high for 6 clock cycles, and then waits until, 
--				  matrix multiplication calculations are all finished
----------------------------------------------------------------------------------	
	-- Calculate each coefficient and write to SRAM
   stim_proc_write: process
   begin		
      -- hold reset state for 100ms.
		TOP_in_BTN_RST_TB <= '1';
      wait for 500 ns;
		TOP_in_BTN_RST_TB <= '0';
		
      wait for clk_period*5;
		
		-- start the calculation
		TOP_in_BTN_CALC_TB <= '1';
		wait for clk_period*5;
		TOP_in_BTN_CALC_TB <= '0';
		
		-- wait until calculation process has finished
		wait until TOP_out_COMPLETE_TB = '1';
		
		-- set flag : used by other process
		tmp_start_disp_flag <= '1';
		wait;		
		
	end process;

end;
