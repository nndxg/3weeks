----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:33:31 11/27/2017 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
	Port(
	input1:in STD_LOGIC_VECTOR(15 downto 0);
	input2:in STD_LOGIC_VECTOR(15 downto 0);
	contro:in STD_LOGIC_VECTOR(3 downto 0);
	result:out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	branch:out STD_LOGIC
	);
end ALU;

architecture Behavioral of ALU is

begin
	process(input1,input2,contro)
	begin
		case contro is 
			when "0001" => --  +
				result <= input1 + input2;
				branch <= '0';
			when "0010" => --  -
				result <= input1 - input2;
				branch <= '0';
			when "0011" => --  AND
				result <= input1 and input2;
				branch <= '0';
			when "0100" => --  OR
				result <= input1 or input2;
			branch <= '0';
			when "0101" => -- NOT
				result <= not input1;
				branch <= '0';
			when "0110" => --SLL
				if (input2 = "0000000000000000") then 
					result <= to_stdlogicvector(to_bitvector(input1) sll 8);--left 8
				else 
					result <= to_stdlogicvector(to_bitvector(input1) sll conv_integer(input2));
				end if;
				branch <= '0';
			when "1100" => --SRLV
				result <= to_stdlogicvector(to_bitvector(input1) srl conv_integer(input2));
				branch <= '0';
			when "0111" => --  SRA
				if (input2 = "0000000000000000") then 
					result <= to_stdlogicvector(to_bitvector(input1) sra 8);--left 8
				else 
					result <= to_stdlogicvector(to_bitvector(input1) sra conv_integer(input2));
				end if;
				branch <= '0';
			when "1101" => --SLTUI
				if (input1 < input2) then 
					result <= "0000000000000001";
				else
					result <= "0000000000000000";
				end if;
				branch <= '0';
			when "1000" => -- cmp , cmpi
				if (input1 = input2) then 
					result <= "0000000000000000";
				else 
					result <= "0000000000000001";
				end if;
				branch <= '0';
			when "1001" => --BEQZ, BTEQZ
				if (input1 = "0000000000000000") then
					branch <= '1';
				else 
					branch <= '0';
				end if;
				result <= "0000000000000000";
			when "1010" => --B
				branch <= '1';
				result <= "0000000000000000";
			when "1011" => --BNEZ, BTNEZ 
				if (input1 = "0000000000000000") then
					branch <= '0';
				else 
					branch <= '1';
				end if;
				result <= "0000000000000000";
			when "1110" => --input1
				result <= input1;
				branch <= '0';
			when "1111" => --input2
				result <= input2;
				branch <= '0';
				
			when others => result <= "0000000000000000";
				branch <= '0';
		end case;
	end process;

end Behavioral;

