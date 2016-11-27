---------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	14:37:53 02/11/2011
-- Design Name:   	Control
-- Module Name:   	Control - Behavioral 
-- Project Name:  	Lab4a
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Bus Control Logic unit, grants permission for the bus, based
--					on requests being made. Priority is given to the ADC, then
--					the DACs.
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
entity Control is
    port (
        DAC1_REQ	: in STD_LOGIC;		-- DAC1 is requesting control of the bus
        DAC2_REQ	: in STD_LOGIC;		-- DAC2 is requesting control of the bus
        ADC_REQ		: in STD_LOGIC;		-- ADC is requesting control of the bus
        ADC_CTRL	: out STD_LOGIC;	-- ADC has been granted control of the bus
        DAC1_CTRL	: out STD_LOGIC;	-- DAC1 has been granted control of the bus
        DAC2_CTRL	: out STD_LOGIC	-- DAC2 has been granted control of the bus
		);
end Control;

architecture Control_arch of Control is

begin

----------------------------------------------------------------------------------
-- MAIN PROCESS combinational deciding on permissions
----------------------------------------------------------------------------------

-- purely combinational decision making.
-- permission is based on bus_requests.
-- priority is given to ADC.
-- then the DACs, in order of their IDs.
process(DAC1_REQ, DAC2_REQ, ADC_REQ)
begin
	if (ADC_REQ='1') then   -- ADC has priority
	   DAC1_CTRL 	<= '0';
	   DAC2_CTRL 	<= '0';
	   ADC_CTRL 	<= '1';
	elsif (DAC1_REQ='1') then  -- then DAC1
	   DAC2_CTRL 	<= '0';
	   ADC_CTRL 	<= '0';
	   DAC1_CTRL 	<= '1';
	elsif (DAC2_REQ='1') then  -- then DAC2
	   DAC1_CTRL 	<= '0';
	   ADC_CTRL 	<= '0';
	   DAC2_CTRL 	<= '1';
	else                       -- by default, ADC has control of the bus
	   DAC1_CTRL 	<= '0';
	   DAC2_CTRL 	<= '0';
	   ADC_CTRL 	<= '1';
	end if;

end process;
    
end Control_arch;
