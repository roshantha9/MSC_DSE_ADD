----------------------------------------------------------------------------------
-- Company: 	UoY-Elec
-- Engineer: 	106033467
-- 
-- Create Date:    19:53:44 01/27/2011 
-- Design Name:    n-bit adder test bench
-- Module Name:    nbit_adder_tb - Behavioral 
-- Project Name:   Lab2a
-- Target Devices: XUPV5-LX110T - Virtex 5
-- Tool versions:  ISE 10.1
-- Description: nbit_adder (n-bit adder module) Test Bench
--
-- Dependencies: None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- VHDL libraries for standard logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
 
entity nbit_adder_tb is
end;
 
ARCHITECTURE behavior OF nbit_adder_tb IS 
	
	 ----------- modifiable parameters of the test bench ------------
	 constant noBits  	 : natural := 8;	-- number of bits
	 constant clk_period : time := 10 ns;	-- clock period
	 	 
	-- user defined vhdl record containing the test vectors
	-- test inputs and outputs
	type test_io is record
		-- intputs
		CIN_TB : STD_LOGIC;
		X_TB   : STD_LOGIC_VECTOR(noBits-1 downto 0);
		Y_TB   : STD_LOGIC_VECTOR(noBits-1 downto 0);
		
		-- outputs
		SUM_TB  : STD_LOGIC_VECTOR(noBits-1 downto 0);
		COUT_TB : STD_LOGIC;
		
	end record test_io;
	
	
	type test_vector_array is array (natural range <>)
		of test_io;
	constant test_vectors: test_vector_array :=
	-- ( CIN | X | Y | SUM | COUT )
	-- ============================
	
	-- ==== UNCOMMENT/COMMENT AS REQUIRED	
	
	-- Test vectors for N=32
	-- (	   	
		-- ( '0', X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFE", '1' ),      -- 0
		-- ( '0', X"00000000", X"00000000", X"00000000", '0' ),      -- 1
		-- ( '0', X"FF000000", X"FF000000", X"FE000000", '1' ),      -- 2
		-- ( '0', X"000000FF", X"000000FF", X"000001FE", '0' ),      -- 3
		-- ( '1', X"0F000000", X"0F0000F0", X"1E0000F1", '0' ),      -- 4
		-- ( '0', X"000000AB", X"AB000000", X"AB0000AB", '0' ),      -- 5
		-- ( '0', X"7FFFFFFF", X"7FFFFFFF", X"FFFFFFFE", '0' ),      -- 6
		-- ( '0', X"3FFFFFFF", X"FF000000", X"3EFFFFFF", '1' ),      -- 7
		-- ( '0', X"CC000000", X"3FFFFFFF", X"0BFFFFFF", '1' ),      -- 8
		-- ( '0', X"0000FF00", X"FF0000FF", X"FF00FFFF", '0' )      -- 9
	-- );    
	
	-- Test vectors for N=8
	(
		( '0', X"FF", X"FF", X"FE", '1' ),      -- 0
		( '0', X"00", X"00", X"00", '0' ),      -- 1
		( '0', X"F0", X"F0", X"E0", '1' ),      -- 2
		( '0', X"0F", X"0F", X"1E", '0' ),      -- 3
		( '1', X"0F", X"F0", X"00", '1' ),      -- 4
		( '0', X"0A", X"0B", X"15", '0' ),      -- 5
		( '0', X"80", X"80", X"00", '1' ),      -- 6
		( '0', X"40", X"40", X"80", '0' ),      -- 7
		( '0', X"C0", X"3F", X"FF", '0' ),      -- 8
		( '0', X"00", X"F1", X"F1", '0' )       -- 9
	);
	
	 -----------------------------------------------------------------	 
	 
	-- using the nbit_adder module 
	component nbit_adder
		generic ( width : NATURAL := noBits );
		port (ADDER_X, ADDER_Y   : in  STD_LOGIC_VECTOR(noBits-1 downto 0);
				ADDER_CIN  			 : in STD_LOGIC;
				ADDER_SUM  			 : out STD_LOGIC_VECTOR(noBits-1 downto 0);
				ADDER_COUT 			 : out STD_LOGIC );
	end component; 
	 
	 	 
	-- Adder inputs - temporary signals (used for port mapping)
   signal ADDER_X_TB 	  : std_logic_vector(noBits-1 downto 0) := (others => '0');
   signal ADDER_Y_TB 	  : std_logic_vector(noBits-1 downto 0) := (others => '0');
   signal ADDER_CIN_TB    : std_logic := '0';
   
   -- Adder outputs - temporary signals (used for port mapping)
   signal ADDER_SUM_TB    : std_logic_vector(noBits-1 downto 0);
   signal ADDER_COUT_TB   : std_logic;
 
begin
 
	-- Instantiate the Unit Under Test (UUT) - n-bit Adder
   uut: nbit_adder
		  generic map (width => noBits)
		  port map(
          ADDER_X => ADDER_X_TB,
          ADDER_Y => ADDER_Y_TB,
          ADDER_CIN => ADDER_CIN_TB,
          ADDER_SUM => ADDER_SUM_TB,
          ADDER_COUT => ADDER_COUT_TB
        );		  
 
   -- Stimulus process
   -- A self checking test bench
   stim_proc: process
   begin		
      
		 ADDER_X_TB 		<= conv_std_logic_vector(0, noBits);   
		 ADDER_Y_TB 		<= conv_std_logic_vector(0, noBits);
		 ADDER_CIN_TB 		<= '0';
		 
		 wait for clk_period*50;
		
	  -- loop through the test cases	      	
	  for i in 	test_vectors'range loop
		
		-- inputs X,Y and CIN
		ADDER_X_TB 	 <= test_vectors(i).X_TB;
		ADDER_Y_TB 	 <= test_vectors(i).Y_TB;
		ADDER_CIN_TB <=	test_vectors(i).CIN_TB;
		
		wait for clk_period*2;
		
		-- validate sum,cout output , notify if incorrect
		assert ((ADDER_SUM_TB = test_vectors(i).SUM_TB) and 
				(ADDER_COUT_TB = test_vectors(i).COUT_TB))
		report "FAIL!:Test Vector " & integer'image(i) & " failed!"					
		severity warning;
		
		wait for clk_period*2;
		
	  end loop;
	  
	  wait; -- wait indefinitely *end of testing*
	  
   end process;

end;
