----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:04:30 11/27/2017 
-- Design Name: 
-- Module Name:    ReadDstMUX - Behavioral 
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

entity ReadDstMUX is
	port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			four_downto_two : in std_logic_vector(2 downto 0);
			contro : in std_logic_vector(2 downto 0);
			
			ReadDstOut : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1110"=没有
		);
end ReadDstMUX;

architecture Behavioral of ReadDstMUX is

begin
	process(ten_downto_eight,seven_downto_five,four_downto_two,contro)
	begin
		case contro is
			when "001" =>		--(10,8)
				ReadDstOut <= '0' & ten_downto_eight;
			when "010" =>		--(7,5)
				ReadDstOut <= '0' & seven_downto_five;
			when "011" =>		--(4,2)
				ReadDstOut <= '0' & four_downto_two;
			when "100" =>		--T
				ReadDstOut <= "1010";
			when "101" =>		--SP
				ReadDstOut <= "1000";
			when "110" =>		--IH
				ReadDstOut <= "1001";
			when others =>		--No ReadDst
				ReadDstOut <= "1110";
		end case;
	end process;

end Behavioral;

