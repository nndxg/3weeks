----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:40:07 11/29/2017 
-- Design Name: 
-- Module Name:    MemWbRegisters - Behavioral 
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

entity MemWbRegisters is
	port(
		rst: in std_logic;
		clk: in std_logic;
		flashFinished : in std_logic;
		ExeMemRegWrite: in std_logic;
		ExeMemWBSrc: in std_logic;
		MemReadData: in std_logic_vector(15 downto 0);
		ALUResult: in std_logic_vector(15 downto 0);
		ExeMemWriteReg: in std_logic_vector(3 downto 0);
		
		MemWbRegWrite: out std_logic;
		MemWbWriteReg: out std_logic_vector(3 downto 0);
		WriteData: out std_logic_vector(15 downto 0)
	);
end MemWbRegisters;

architecture Behavioral of MemWbRegisters is

begin

	process(rst, clk)
	begin 
		if (rst = '0') then
			MemWbRegWrite <= '0';
			MemWbWriteReg <= "1110";   -- ±íÊ¾²»Ð´¼Ä´æÆ÷
			WriteData <= (others => '0');
		elsif (rising_edge(clk)) then
			if(flashFinished = '1') then
				MemWbRegWrite <= ExeMemRegWrite;
				MemWbWriteReg <= ExeMemWriteReg;
				if (ExeMemWBSrc = '1') then
					WriteData <= MemReadData;
				else
					WriteData <= ALUResult;
				end if;
			else
				null;
			end if;
		else
			null;
		end if;
	end process;

end Behavioral;

