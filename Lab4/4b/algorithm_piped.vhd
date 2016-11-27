----------------------------------------------------------------------------------
-- Company: 		UoY-Elec
-- Engineer: 		106033467
-- 
-- Create Date:    	02:35:14 03/06/2011 
-- Design Name:    	algorithm_piped
-- Module Name:    	algorithm_piped - Behavioral 
-- Project Name:   	Lab4b
-- Target Devices: 	XUPV5-LX110T - Virtex 5
-- Tool versions: 	ISE 10.1
-- Description: 	Accelerated Algorithm using Pipelining. Imeplementation of
--					5-pipeline stages.
--
-- Dependencies: 	None
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
entity algorithm_piped is
    Port ( RST : in STD_LOGIC;
		   A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           C : in  STD_LOGIC_VECTOR (15 downto 0);
           D : in  STD_LOGIC_VECTOR (31 downto 0);
		   CLK: in STD_LOGIC;
		   overflow: out STD_LOGIC;
           O : out  STD_LOGIC_VECTOR (63 downto 0)
		);
end algorithm_piped;

architecture Behavioral of algorithm_piped is

----------------------------------------------------------------------------------
-- Shift left unit declaration
----------------------------------------------------------------------------------
component shiftleftN
	generic( width : natural := 64 );
	port(
			SHL_in_A	: in STD_LOGIC_VECTOR(64-1 downto 0);
			SHL_in_N : in STD_LOGIC_VECTOR(64-1 downto 0);				
			SHL_out_RESULT : out STD_LOGIC_VECTOR(64-1 downto 0)
		);
end component;


----------------------------------------------------------------------------------
-- Temporary signals used for wiring, and to infer basic components
----------------------------------------------------------------------------------
-- signals used for zero padding
signal tmp_zeros32	: STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');

-- temp signals for buffers as input regs. (stage 1)
signal reg_InA : STD_LOGIC_VECTOR (15 downto 0);
signal reg_InB : STD_LOGIC_VECTOR (15 downto 0);
signal reg_InC : STD_LOGIC_VECTOR (15 downto 0);
signal reg_InD : STD_LOGIC_VECTOR (31 downto 0);

-- temp signals for regs (stage 2) - before the multiplier
signal reg_SubAOut : STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
signal reg_Stage2B : STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
signal reg_Stage2C : STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
signal reg_Stage2D : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');

-- temp signals for regs (stage 3) - after the multiplier
signal reg_MulAOut : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
signal reg_Stage3C : STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
signal reg_Stage3D : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');

signal mulAOut	: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal subAOut : STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');

-- first addition unit(33 bit output), 1 bit overflow capture
signal tmpAddUnit1Out : STD_LOGIC_VECTOR ( 32 downto 0) := (others => '0');
signal tmpOvr1		  : STD_LOGIC := '0';

-- left shifter output
signal tmpShiftNInA	   : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');
signal tmpShiftNInB	   : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');
signal tmpShiftNOut    : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');

-- stage 4 regs
signal reg_Add1Out	   : STD_LOGIC_VECTOR ( 32 downto 0) := (others => '0');
signal reg_Stage4D	   : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
signal ff_Stage4Ovr	   : STD_LOGIC;

-- stage 5 regs
signal reg_ShiftNOut    : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');
signal reg_Stage5D		: STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
signal ff_Stage5Ovr		: STD_LOGIC;

-- second addition unit (65 bit output), 1 bit overflow capture
signal tmpAddUnit2Out  : STD_LOGIC_VECTOR( 64 downto 0 ) := (others => '0');
signal tmpOvr2		   : STD_LOGIC;

signal tmpSubOut	   : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');
signal regOutput	   : STD_LOGIC_VECTOR( 63 downto 0 ) := (others => '0');
signal regOvr		   : STD_LOGIC;


begin

----------------------------------------------------------------------
--	Stage 1 Pipe
----------------------------------------------------------------------

-- stage 1 registers
p_InBuffer: process is
begin
	wait until rising_edge(CLK);
	-- synchronous reset
	if(RST='1') then
		reg_InA <= (others => '0');
		reg_InB <= (others => '0');
		reg_InC <= (others => '0');
		reg_InD <= (others => '0');
	else
		reg_InA <= A;
		reg_InB <= B;
		reg_InC <= C;
		reg_InD <= D;		
	end if;
		
end process p_InBuffer;

-- Calculation : (A-3)
subAOut <= (reg_InA - conv_std_logic_vector(3, 15)); 


----------------------------------------------------------------------
--	Stage 2 Pipe
----------------------------------------------------------------------

-- stage 2 registers
p_Stage2Buffers: process is
begin
	
	wait until rising_edge(CLK);
	-- synchronous reset
	if(RST='1') then
		reg_SubAOut <= (others => '0');
		reg_Stage2B <= (others => '0');
		reg_Stage2C <= (others => '0');
		reg_Stage2D <= (others => '0');
	else
		reg_SubAOut <= subAOut;		-- output of the subtraction calc.
		reg_Stage2B <= reg_InB;
		reg_Stage2C <= reg_InC;
		reg_Stage2D <= reg_InD;
	end if;
	
end process p_Stage2Buffers;

-- Calculation : (A-3)*B
mulAOut <= (reg_Stage2B) * (reg_SubAOut);

----------------------------------------------------------------------
--	Stage 3 Pipe
----------------------------------------------------------------------

-- stage 3 registers
p_Stage3Buffers: process is
begin
	
	wait until rising_edge(CLK);
	-- synchronous reset
	if(RST='1') then
		reg_MulAOut <= (others => '0');
		reg_Stage3C <= (others => '0');
		reg_Stage3D <= (others => '0');
	else		
		reg_MulAOut <= mulAOut;		-- output of the multiplication
		reg_Stage3C <= reg_Stage2C;
		reg_Stage3D <= reg_Stage2D;
	end if;	
	
end process p_Stage3Buffers;

-- Calculation : ((A-3)*B)+C
tmpAddUnit1Out <= (('0' & reg_MulAOut) + ("00000000000000000" & reg_Stage3C));
-- overflow of the addition calculation (MSB)
tmpOvr1 <= tmpAddUnit1Out(32);

----------------------------------------------------------------------
--	Stage 4 Pipe
----------------------------------------------------------------------	 
-- stage 4 registers
p_Stage4Buffers: process is
begin
	
	wait until rising_edge(CLK);
	-- synchronous reset
	if(RST='1') then
		reg_Add1Out  <= (others => '0');
		reg_Stage4D  <= (others => '0');
		ff_Stage4Ovr <= '0';
	else
		reg_Add1Out  <= tmpAddUnit1Out;	-- output of addition unit (+C)
		reg_Stage4D  <= reg_Stage3D;
		ff_Stage4Ovr <= tmpOvr1;		-- addition overflow
	end if;	
	
end process p_Stage4Buffers;

-- inputs to the Shift Unit , being resized.
tmpShiftNInA <= (tmp_zeros32 & reg_Add1Out(31 downto 0));
tmpShiftNInB <= (tmp_zeros32 & reg_Stage4D);


-- Calculation : (((A-3)*B)+C)*D
--- SHIFT UNIT
-- left shift unit instantiation
i_ShiftleftN: shiftleftN 
	  generic map(width => 64 )
	  port map (
		  SHL_in_A => tmpShiftNInA,
		  SHL_in_N => tmpShiftNInB,
		  SHL_out_RESULT => tmpShiftNOut
	  );

	  
----------------------------------------------------------------------
--	Stage 5 Pipe
----------------------------------------------------------------------	    
	  
-- stage 5 registers
p_Stage5Buffers: process is
begin
	wait until rising_edge(CLK);
	
	if(RST='1') then
		reg_ShiftNOut <= (others => '0');
		reg_Stage5D   <= (others => '0');
		ff_Stage5Ovr  <= '0';
	else
		reg_ShiftNOut <= tmpShiftNOut;	-- output of the Shift Unit
		reg_Stage5D <= reg_Stage4D;
		ff_Stage5Ovr <= ff_Stage4Ovr;	-- bringing down the adder overflow
	end if;
	
end process p_Stage5Buffers;		  

-- Calculation : ((((A-3)*B)+C)*D)+5
tmpAddUnit2Out <= ('0' & reg_ShiftNOut) + 5;
tmpOvr2 <= tmpAddUnit2Out(64);	-- addition overflow (MSB)

-- Calculation : (((((A-3)*B)+C)*D)+5)-D
tmpSubOut <= tmpAddUnit2Out(63 downto 0) - (tmp_zeros32 & reg_Stage5D);

----------------------------------------------------------------------
--	Output Register
----------------------------------------------------------------------	 

-- placing register at the output of the unit
p_OutBuffer: process is
begin
	wait until rising_edge(CLK);		
	-- synchronous reset
	if(RST='1') then
		regOutput <= (others => '0');	
		regOvr 	  <= '0';		
	else
		regOutput <= tmpSubOut;		-- output of the subtraction
		regOvr <= ff_Stage5Ovr or tmpOvr2;	-- overflows	
	end if;
			
end process;

O <= regOutput;			-- final algorithm output
overflow <= regOvr;		-- final overflow of the algorithm calculation

end Behavioral;

