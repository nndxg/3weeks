----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:12:30 11/29/2017 
-- Design Name: 
-- Module Name:    PCBrancherAdder - Behavioral 
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

entity PCBrancherAdder is
	port(
		PCPlusOne: in std_logic_vector(15 downto 0);
		IdExeImme: in std_logic_vector(15 downto 0);
		PCAfterBranch: out std_logic_vector(15 downto 0)
	);
end PCBrancherAdder;

architecture Behavioral of PCBrancherAdder is

begin

	PCAfterBranch <= PCPlusOne + IdExeImme;

end Behavioral;

