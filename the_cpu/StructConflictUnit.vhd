----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:07:39 11/29/2017 
-- Design Name: 
-- Module Name:    StructConflictUnit - Behavioral 
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

entity StructConflictUnit is
	port(
		IdExeMemWrite: in std_logic;
		ALUResult: in std_logic_vector(15 downto 0);
		IfIdFlush_StructConflict: out std_logic;
		IdExeFlush_StructConflict: out std_logic;
		PCRollBack: out std_logic
	);
end StructConflictUnit;

architecture Behavioral of StructConflictUnit is

begin

	process(IdExeMemWrite, ALUResult)
	begin 
		if ((IdExeMemWrite = '1') and (ALUResult >= x"4000") and (ALUResult <= x"7FFF")) then
			IfIdFlush_StructConflict <= '1';
			IdExeFlush_StructConflict <= '1';
			PCRollBack <= '1';
		else
			IfIdFlush_StructConflict <= '0';
			IdExeFlush_StructConflict <= '0';
			PCRollBack <= '0';
		end if;
	end process;

end Behavioral;

