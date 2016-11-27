---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	14:37:53 02/11/2011
-- Design Name:   	DAC
-- Module Name:   	DAC - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	When dac_sel is equal to the dac_id, the value on the bus is
--					taken from the bidirectional data bus and outputs on the 
--					4-bit led.
--
-- Dependencies: 	None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

----------------------------------------------------------------------------------
-- Eneity declaration
----------------------------------------------------------------------------------

entity DAC is
    port (
        CLK				: in STD_LOGIC;						
        CLK_EN			: in STD_LOGIC;						
        RST				: in STD_LOGIC;	
		-- bidirectional bus
        DATA_BUS		: inout STD_LOGIC_VECTOR (3 downto 0);
		-- what is displayed on the LEDs		
        LED				: out STD_LOGIC_VECTOR (3 downto 0);
		-- ID of the component that the source is talking to 		
        DAC_SEL			: in STD_LOGIC_VECTOR (3 downto 0);
		-- request to have control of the data bus		
        BUS_REQ			: out STD_LOGIC;	
		-- bus control has been granted
		BUS_GRANTED		: in STD_LOGIC;
		-- unique ID for the component (between 1 and F)		
		DAC_ID			: in STD_LOGIC_VECTOR (3 downto 0)		
    );
end DAC;


architecture DAC_arch of DAC is

	signal data_out : STD_LOGIC_VECTOR (3 downto 0);  -- the acknowledge value

begin

----------------------------------------------------------------------------------
-- MAIN PROCESS BLOCK - infers registers and a comparator
----------------------------------------------------------------------------------

process(CLK)
begin
	-- on rising edge
    if CLK'EVENT and CLK='1' then  
		-- synchronous reset
		if RST = '1' then
			LED <= "0000";
		    data_out <= "0000";
			BUS_REQ <= '0';
		else
			if CLK_EN = '1' then
				-- if the source is addressing this target
				if DAC_SEL = DAC_ID then
					-- if the source is sending data
					if BUS_GRANTED = '0' then 	
						LED <= DATA_BUS;	-- display the data  	
						BUS_REQ <= '1';		-- request control of the bus
						data_out <= DAC_ID;
					else					-- if currently in control of the bus
						BUS_REQ <= '0';		-- on the next CK stop requesting it
						data_out <= "0000";	-- and reset the acknowledge
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

-- acknowledge with unique ID on the bus
DATA_BUS <= DATA_OUT when BUS_GRANTED = '1' else "ZZZZ"; 

end DAC_arch;
