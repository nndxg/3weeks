----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:50:50 11/27/2017 
-- Design Name: 
-- Module Name:    ReadReg1MUX - Behavioral 
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

entity ReadReg1MUX is
	port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			
			contro : in std_logic_vector(2 downto 0);
			
			ReadReg1Out : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1111"=没有
		);
end ReadReg1MUX;

architecture Behavioral of ReadReg1MUX is

begin
	process(ten_downto_eight,seven_downto_five,contro)
	begin
		case contro is
			when "001" =>		--(10,8)
				ReadReg1Out <= '0' & ten_downto_eight;
			when "010" =>		--(7,5)
				ReadReg1Out <= '0' & seven_downto_five;
			when "100" =>		--T
				ReadReg1Out <= "1010";
			when "101" =>		--SP
				ReadReg1Out <= "1000";
			when "110" =>		--IH
				ReadReg1Out <= "1001";
			when others =>		--No ReadReg1
				ReadReg1Out <= "1111";
		end case;
	end process;


end Behavioral;

