----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:51:04 11/29/2017 
-- Design Name: 
-- Module Name:    PCMux - Behavioral 
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

entity PCMux is
	port(
		PCPlusOne: in std_logic_vector(15 downto 0);
		ALUResult: in std_logic_vector(15 downto 0);
		PCAfterBranch: in std_logic_vector(15 downto 0);
		isJump: in std_logic;
		willBranch: in std_logic;
		PCRollBack: in std_logic;
		
		selectedPC: out std_logic_vector(15 downto 0)
	);
end PCMux;

architecture Behavioral of PCMux is

begin

	process(PCPlusOne, ALUResult, PCAfterBranch, isJump, willBranch, PCRollBack)
	begin
		if (willBranch = '1') then
			selectedPC <= PCAfterBranch;
		elsif (isJump = '1') then
			selectedPC <= ALUResult;
		elsif (PCRollBack = '1') then
			selectedPC <= PCPlusOne - "0000000000000010";
		else
			selectedPC <= PCPlusOne;
		end if;
	end process;

end Behavioral;

