----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:28:39 11/27/2017 
-- Design Name: 
-- Module Name:    Register - Behavioral 
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

entity Registers is
	Port(
		clk:in std_logic;
		rst:in std_logic;
		RegWrite:in std_logic;
		readReg1:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T
		readReg2:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7
		WriteReg:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T
		WriteData:in std_logic_vector(15 downto 0);
		readData1:out std_logic_vector(15 downto 0);
		readData2:out std_logic_vector(15 downto 0)
	);
end Registers;

architecture Behavioral of Registers is
	signal r0 : std_logic_vector(15 downto 0);
	signal r1 : std_logic_vector(15 downto 0);
	signal r2 : std_logic_vector(15 downto 0);
	signal r3 : std_logic_vector(15 downto 0);
	signal r4 : std_logic_vector(15 downto 0);
	signal r5 : std_logic_vector(15 downto 0);
	signal r6 : std_logic_vector(15 downto 0);
	signal r7 : std_logic_vector(15 downto 0);
	signal T : std_logic_vector(15 downto 0);
	signal IH : std_logic_vector(15 downto 0);
	signal SP : std_logic_vector(15 downto 0);

begin
	process(clk, rst)
	begin
		if (rst = '0') then
			r0 <= (others => '0');
			r1 <= (others => '0');
			r2 <= (others => '0');
			r3 <= (others => '0');
			r4 <= (others => '0');
			r5 <= (others => '0');
			r6 <= (others => '0');
			r7 <= (others => '0');
			T <= (others => '0');
			IH <= (others => '0');			
			SP <= (others => '0');
			
		elsif (clk'event and clk = '1') then
			if (RegWrite = '1') then 
				case WriteReg is 
					when "0000" => r0 <= WriteData;
					when "0001" => r1 <= WriteData;
					when "0010" => r2 <= WriteData;
					when "0011" => r3 <= WriteData;
					when "0100" => r4 <= WriteData;
					when "0101" => r5 <= WriteData;
					when "0110" => r6 <= WriteData;
					when "0111" => r7 <= WriteData;
					when "1000" => SP <= WriteData;
					when "1001" => IH <= WriteData;
					when "1010" => T <= WriteData;
					when others =>
				end case;
			else
			end if;
		else
		end if;
	end process;
	
	process(readReg1,readReg2,r0,r1,r2,r3,r4,r5,r6,r7,SP,IH,T)
	begin
		case readReg1 is 
			when "0000" => readData1 <= r0;
			when "0001" => readData1 <= r1;
			when "0010" => readData1 <= r2;
			when "0011" => readData1 <= r3;
			when "0100" => readData1 <= r4;
			when "0101" => readData1 <= r5;
			when "0110" => readData1 <= r6;
			when "0111" => readData1 <= r7;
			when "1000" => readData1 <= SP;
			when "1001" => readData1 <= IH;
			when "1010" => readData1 <= T;
			when others =>
		end case;
		
		case readReg2 is
			when "0000" => readData2 <= r0;
			when "0001" => readData2 <= r1;
			when "0010" => readData2 <= r2;
			when "0011" => readData2 <= r3;
			when "0100" => readData2 <= r4;
			when "0101" => readData2 <= r5;
			when "0110" => readData2 <= r6;
			when "0111" => readData2 <= r7;
			when others =>
		end case;
		
	end process;

end Behavioral;

