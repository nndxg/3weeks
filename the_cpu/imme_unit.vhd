----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:33:58 11/27/2017 
-- Design Name: 
-- Module Name:    imme_unit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:54:30 11/24/2017 
-- Design Name: 
-- Module Name:    Imme_unit - Behavioral 
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

entity imme_unit is
	port(
				 Im_in : in std_logic_vector(10 downto 0);
				 Im_select : in std_logic_vector(2 downto 0);			 
				 Im_out : out std_logic_vector(15 downto 0)
			);
end imme_unit;

architecture Behavioral of imme_unit is
constant FIVE0 : STD_LOGIC_VECTOR (4 downto 0) := "00000";
constant FIVE1 : STD_LOGIC_VECTOR (4 downto 0) := "11111";
constant EIGHT0 : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
constant EIGHT1 : STD_LOGIC_VECTOR (7 downto 0) := "11111111";
constant ELEVEN0 : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
constant ELEVEN1 : STD_LOGIC_VECTOR (10 downto 0) := "11111111111";
constant TWELVE0 : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
constant TWELVE1 : STD_LOGIC_VECTOR (11 downto 0) := "111111111111";
constant THIRTEEN0 : STD_LOGIC_VECTOR (12 downto 0) := "0000000000000";
constant THIRTEEN1 : STD_LOGIC_VECTOR (12 downto 0) := "1111111111111";
begin
	process(Im_in, Im_select)
	begin
		case Im_select is
			when "110" =>
				case Im_in(10) is
					when '1' => 
						Im_out(15 downto 11) <= FIVE1;
						Im_out(10 downto 0) <= Im_in(10 downto 0);
					when '0' => 
						Im_out(15 downto 11) <= FIVE0;
						Im_out(10 downto 0) <= Im_in(10 downto 0);
					when others =>
				end case;
			when "011" =>
				Im_out(15 downto 3) <= THIRTEEN0;
				Im_out(2 downto 0) <= Im_in(4 downto 2);
			when "100" =>
				Im_out(15 downto 8) <= EIGHT0;
				Im_out(7 downto 0) <= Im_in(7 downto 0);
			when "001" =>
				case Im_in(3) is
					when '1' => 
						Im_out(15 downto 4) <= TWELVE1;
						Im_out(3 downto 0) <= Im_in(3 downto 0);
					when '0' => 
						Im_out(15 downto 4) <= TWELVE0;
						Im_out(3 downto 0) <= Im_in(3 downto 0);
					when others =>
				end case;
			when "010" =>
				case Im_in(4) is
					when '1' => 
						Im_out(15 downto 5) <= ELEVEN1;
						Im_out(4 downto 0) <= Im_in(4 downto 0);
					when '0' => 
						Im_out(15 downto 5) <= ELEVEN0;
						Im_out(4 downto 0) <= Im_in(4 downto 0);
					when others =>
				end case;
			when "101" =>
				case Im_in(7) is
					when '1' => 
						Im_out(15 downto 8) <= EIGHT1;
						Im_out(7 downto 0) <= Im_in(7 downto 0);
					when '0' => 
						Im_out(15 downto 8) <= EIGHT0;
						Im_out(7 downto 0) <= Im_in(7 downto 0);
					when others =>
				end case;
			when others =>
		end case;
	end process;
end Behavioral;