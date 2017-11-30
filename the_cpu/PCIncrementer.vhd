----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:42:52 11/29/2017 
-- Design Name: 
-- Module Name:    PCIncrementer - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCIncrementer is
	port(
		PCin: in std_logic_vector(15 downto 0);
		PCPlusOne: out std_logic_vector(15 downto 0)
	);
end PCIncrementer;

architecture Behavioral of PCIncrementer is

begin

	PCPlusOne <= PCin + "0000000000000001";

end Behavioral;

