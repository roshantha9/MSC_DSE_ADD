----------------------------------------------------------------------------------
-- Company:         UoY-Elec
-- Engineer:        106033467 
-- Create Date:     18:35:57 02/10/2011 
-- Design Name:     SRAM model
-- Module Name:     SRAM - Behavioral 
-- Project Name:    Lab3b
-- Target Devices:  XUPV5-LX110T - Virtex 5
-- Tool versions:   ISE 10.1
-- Description:     SRAM model designed using array type and data i/o and
--					address registers
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
entity SRAM is
generic ( word_len 		: NATURAL := 36;
		  adr_size 		: NATURAL := 18);
port (
		SRAM_CLK	: in STD_LOGIC;		-- clock
		SRAM_ADDR_M : in  STD_LOGIC_VECTOR(adr_size-1 downto 0);	-- r/w address
		SRAM_DATA_M : inout STD_LOGIC_VECTOR(word_len-1 downto 0); -- data io bus
		SRAM_CEn 	: in STD_LOGIC;	-- chip enable
		SRAM_OEn 	: in STD_LOGIC;	-- output enable
		SRAM_WEn 	: in STD_LOGIC    -- write enable
    );


end SRAM;

architecture Behavioral of SRAM is
	
	
	-- an array of RAM --
	type mem_array_type is array (0 to 2**adr_size-1)
						of std_logic_vector(word_len-1 downto 0);	

----------------------------------------------------------------------------------
-- Temporary signal and register declaration
----------------------------------------------------------------------------------
	-- array					
	signal sram_mem_arr : mem_array_type;
	
	-- read/write flags
	signal read_condition	: STD_LOGIC := '0';
	signal write_condition	: STD_LOGIC := '0';	
	-- data i/o regs
	signal data_in_tmp		: STD_LOGIC_VECTOR(word_len-1 downto 0) := (others => '0');
	signal data_out_tmp  	: STD_LOGIC_VECTOR(word_len-1 downto 0) := (others => '0');
	-- address reg
	signal addr_reg 		: STD_LOGIC_VECTOR(adr_size-1 downto 0) := (others => '0');
	-- WE wait for two clock cycles
	signal we_dff1 			: STD_LOGIC := '0';
	signal we_dff2 			: STD_LOGIC := '0';
	
begin   
	
  read_condition 	<= (not we_dff2);
  write_condition 	<= we_dff2;

	-- Data output bus
  SRAM_DATA_M 		<= data_out_tmp when SRAM_OEn = '0'
									else (others => 'Z');
								
  data_in_tmp 		<= SRAM_DATA_M;
	
----------------------------------------------------------------------------------
-- 2 DFFs to HOLD the WEn and CEn value for 2 clock cycles
----------------------------------------------------------------------------------  
  -- hold the write-enable line for two clock cycles
  sram_we_dff: process is
  begin
	wait until rising_edge(SRAM_CLK);
	--if (SRAM_CEn = '0') then
		we_dff1 <= (not SRAM_WEn) and (not SRAM_CEn);
		we_dff2 <= we_dff1;
	--end if;
  end process;  

----------------------------------------------------------------------------------
-- Address register, with clock enable
----------------------------------------------------------------------------------      
  -- Addr registers
  sram_addr: process is
  begin
	wait until rising_edge(SRAM_CLK);
	if (SRAM_CEn = '0') then
		addr_reg <= SRAM_ADDR_M;
	else
		addr_reg <= addr_reg;
	end if;
  end process;
  
----------------------------------------------------------------------------------
-- Read registers, with clock enable
----------------------------------------------------------------------------------   
  sram_read: process is
  begin
    wait until rising_edge(SRAM_CLK);
	 if (read_condition = '1') then
      data_out_tmp <= sram_mem_arr(conv_integer(addr_reg));
    end if;    
  end process;
 
----------------------------------------------------------------------------------
-- Write registers, with clock enable
----------------------------------------------------------------------------------  
  sram_write: process is
  begin
	 wait until rising_edge(SRAM_CLK);
    if (write_condition = '1') then
      sram_mem_arr(conv_integer(addr_reg)) <= data_in_tmp;	
    end if;
  end process;
  




end Behavioral;

