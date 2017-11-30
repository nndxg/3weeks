----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:41:00 11/29/2017 
-- Design Name: 
-- Module Name:    PCRegister - Behavioral 
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

entity PCRegister is
	port(
		rst: in std_logic;
		clk: in std_logic;
		PCKeep: in std_logic;
		selectedPC: in std_logic_vector(15 downto 0);
		nextPC: out std_logic_vector(15 downto 0)
	);
end PCRegister;

architecture Behavioral of PCRegister is

begin

	process(rst, clk)
	begin 
		if (rst = '0') then
			nextPC <= "1111111111111111";
		elsif (rising_edge(clk)) then
			if (PCKeep = '0') then
				nextPC <= selectedPC;
			end if;
		end if;
	end process;

end Behavioral;

