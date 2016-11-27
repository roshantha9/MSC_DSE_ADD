---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	14:37:53 02/11/2011
-- Design Name:   	ADC
-- Module Name:   	ADC - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Analog to Digital Converter (Target)
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
use IEEE.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- Eneity declaration
----------------------------------------------------------------------------------

entity ADC is
    port (
    	  CLK: in STD_LOGIC;		
    	  CLK_EN: in STD_LOGIC;		
    	  RST: in STD_LOGIC;
		  -- control of the bus has been granted
		  BUS_GRANTED: in STD_LOGIC;
		   -- bidirectional data bus
          DATA_BUS: inout STD_LOGIC_VECTOR (3 downto 0);  
          -- request to have control of the data bus
		  BUS_REQ: out STD_LOGIC;				
          -- address of the target (DAC_ID)
		  DAC_SEL: out STD_LOGIC_VECTOR (3 downto 0); 
		  
		  -- taken out for debug purposes --
		  ADC_COUNTER: out STD_LOGIC_VECTOR (3 downto 0)
    );
end ADC;

architecture ADC_arch of ADC is

	signal counter: STD_LOGIC_VECTOR (3 downto 0);
	signal dac_selector: STD_LOGIC_VECTOR (3 downto 0);
	signal bus_request: STD_LOGIC;

begin


----------------------------------------------------------------------------------
-- MAIN PROCESS, infers a state machine, comparator and registers
----------------------------------------------------------------------------------

process(CLK)
begin

	if CLK'EVENT and CLK='1' then
		-- synchronous reset
		if RST = '1' then
			counter <= "0000";
			dac_selector <= "0001";
			bus_request <= '1';
		else
			-- clock enable signal
			if CLK_EN = '1' then
				-- if the LSBs of the counter are '11' 
				-- IMPORTANT : bus_request should be '0' when the switch of 
				-- the targets are being made
				if ((counter(1)='1' and counter(0)='1') 
					
				  and bus_request = '0') then  -- and the data is sent to the bus
					
					-- change dac_select (choose different target)
					-- on the next cycle change target
					if dac_selector = "0010" then 		
						dac_selector <= "0001";
					else
						dac_selector <= "0010";
					end if;
					
				end if;
				
				-- if the data has been sent to the target
				if BUS_GRANTED = '1' then
					-- on the next cycle stop requesting the bus
					bus_request <= '0';					
				else
					-- if the correct acknowledgment has been received
					if (dac_selector = DATA_BUS) then
						-- increment the counter
						counter <= counter + 1;
						-- and request the bus to send the following word
						bus_request <= '1';					
					end if;     	    	
				end if;
				
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------------
-- OUTPUT SELECTION
----------------------------------------------------------------------------------
-- put data on the shared bus when control is granted
DATA_BUS <= counter when BUS_GRANTED = '1' else "ZZZZ"; 
DAC_SEL <= dac_selector;
BUS_REQ <= bus_request;

ADC_COUNTER <= counter;


end ADC_arch;
