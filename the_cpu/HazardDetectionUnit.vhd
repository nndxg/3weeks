----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:24:43 11/29/2017 
-- Design Name: 
-- Module Name:    HazardDetectionUnit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HazardDetectionUnit is
	port(
		IdExeMemRead: in std_logic;
		IdExeWriteReg: in std_logic_vector(3 downto 0);
		readReg1: in std_logic_vector(3 downto 0);
		readReg2: in std_logic_vector(3 downto 0);
		
		IdExeFlush_LW: out std_logic;
		PCKeep: out std_logic;
		IfIdKeep_LW: out std_logic
	);
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is

begin

	process(IdExeMemRead, IeExeWriteReg, readReg1, readReg2)
	begin
		if ((IdExeMemRead = '1') and ((readReg1 = IdExeWriteReg) or (readReg2 = IdExeWriteReg))) then
			IdExeFlush_LW <= '1';
			PCKeep <= '1';
			IfIdKeep_LW <= '1';
		else
			IdExeFlush_LW <= '0';
			PCKeep <= '0';
			IfIdKeep_LW <= '0';
		end if;
	end process;

end Behavioral 