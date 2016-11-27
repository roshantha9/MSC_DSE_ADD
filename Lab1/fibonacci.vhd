----------------------------------------------------------------------------------
-- Advanced Digital Design Lab 1
-- University of York
-- Department of Electronics
-- York, UK
-- Gianluca Tempesti, Yang Liu (Jerry), Tuze Kuyucu - January 2010


-- Design Name: Memory write/access and fibonacci sequence generator
-- Module Name:    fibonacci
-- Description: This code creates a fibonacci sequence and records the sequence to a memory module
-- On the receive of an input and a memory adress it retrieves the recorded value from the memory

-- Dependencies: ram component
--
-- Revision: 1.0

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Write a Fibonnacci sequence of upto 255

entity fibonacci is
generic ( bits: INTEGER:=32; -- memory size
			   words: INTEGER:=256;
				wordSize: INTEGER:=8;
		    	fibonacciSize: INTEGER:=8); --fibonacciSize in terms of number of bits
					
    port ( clock: in STD_LOGIC;
			  loadValues : in  STD_LOGIC; --a button to calculate and load the sequence
           loadMem : in  STD_LOGIC; -- another button to load a value from memLoc
			  memLoc : in STD_LOGIC_VECTOR(fibonacciSize-1 downto 0);
			  doneLoading: out STD_LOGIC;
           Sequence : out  STD_LOGIC_VECTOR (fibonacciSize-1 downto 0)); --retreived value from memLoc
end fibonacci;

architecture Behavioral of fibonacci is

---Define the ram component for simulation
component ram256x32 is
	port(wr_ne : in  STD_LOGIC; -- write not enable
		  chipNenable: in STD_LOGIC; -- chip not enable
		  outputNenable: in STD_LOGIC; --output not enable
		  clock: in STD_LOGIC; -- main clock
		  addr : in  STD_LOGIC_VECTOR(wordSize-1 downto 0); --address
		  data_in : in  STD_LOGIC_VECTOR (bits-1 downto 0);
		  data_out : out  STD_LOGIC_VECTOR (bits-1 downto 0));
end component;

-- constants 
constant memStartAddr: STD_LOGIC_VECTOR(fibonacciSize-1 downto 0):=(others=>'0');
constant totalFibonacciSize: INTEGER:= 256;
		  
signal a_value: STD_LOGIC_VECTOR(bits-1 downto 0):=(others=>'0'); --temporary signal used for retreiving memory data
signal done: STD_LOGIC:='0'; --flag used for the statemachine (initially set to "not done")
signal start: STD_LOGIC:='0';--flag used for the statemachine (initially set to "don't start")
signal clock2: STD_LOGIC:= '0'; --clock for the statemachine

signal memAddress: STD_LOGIC_VECTOR(fibonacciSize-1 downto 0):=(others=>'0'); --used for accessing the ram address
signal memOp: STD_LOGIC; -- memory operation (aka write not enable) : '1' read | '0' write
signal cNe: STD_LOGIC:= '1'; -- chip not enable
signal oNe: STD_LOGIC:= '1'; -- output not enable
signal memContent: STD_LOGIC_VECTOR (bits-1 downto 0); -- what to write to memory

begin
--P1 is the main statemachine for the circuit
	P1:process (loadMem, loadValues,done, start, clock2)
	variable fibonacciCurrent: STD_LOGIC_VECTOR (bits-1 downto 0):=(0=>'1', others=>'0');
	variable fibonacciOld: STD_LOGIC_VECTOR (bits-1 downto 0):=(others=>'0');
	variable fibonacciTemp: STD_LOGIC_VECTOR (bits-1 downto 0):=(others=>'0');
	begin
	--state 1 (X,1,X,X,X) -- the values in the parantheses refer to the sensitivity list
		if(loadValues='1') then
			done<='0';
			start<='1';
			fibonacciOld:= (others=>'0');
			fibonacciCurrent:= (0=>'1', others=>'0');
			memOp<='0';
			cNe<='0';
			oNe<='0';
			memAddress<=memStartAddr;
			memContent<=fibonacciOld;
			
			--U1:ram256x32 port map('0',clock,memStartAddr,fibonacciOld);
			
		else
		--state 2 (X,0,X,1,X)
			if (start='1') then
				done<='0';
				start<='0';
				memOp<='0';
				cNe<='0';
				oNe<='0';
				memAddress<=memStartAddr+1;
				memContent<=fibonacciCurrent;
				
			--	U2:ram256x32 port map('0',clock,memStartAddr+1,fibonacciCurrent);
			
		--state 3 (X,0,0,0,1)
			elsif(done='0' and clock2='1')then
				--for i in 0 to (totalFibonacciSize -1)  loop
				if ( CONV_INTEGER(memAddress-memStartAddr)< (fibonacciSize-1)) then
					fibonacciTemp:= fibonacciCurrent;
					fibonacciCurrent:= fibonacciCurrent + fibonacciOld;
					fibonacciOld:= fibonacciTemp;
					memOp<='0';
					cNe<='0';
					oNe<='0';
					memAddress<=memAddress+1;
					memContent<=fibonacciCurrent;
				--	U2:ram256x32 port map('0',clock,memStartAddr+2+i,fibonacciCurrent);
				else
					done<='1'; -- state (X,1,0)
				end if;
			--state 4 (1,0,1,0,X)
			elsif(done = '1' and loadMem = '1') then
				memOp<='1';
				cNe<='0';
				oNe<='0';
				memAddress<=memLoc;
			--state 5 (0,0,1,0,X)	
			elsif (done = '1') then
				memOp<='1';
				cNe<='1';
				oNe<='1';
			end if;
		end if;
	end process;
	--A clock divider
	P2:process (clock)
		variable delay: integer:=0;
		variable delay2: integer:=0;
	begin
		if (clock='1' and clock'event) then
		 if delay>= 1 then
			clock2<= not clock2;
			delay:=0;
		 else
			delay:= delay+1;
		end if;

	  end if;	
	end process;
	
	--write or read to the ram:
	U1:ram256x32 port map(memOp,cNe,oNe,clock,memAddress,memContent, a_value);
	--output onto the LEDs
	Sequence <= a_value((fibonacciSize-1) downto 0);
	doneLoading<=done;
end Behavioral;
