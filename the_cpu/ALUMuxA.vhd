----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:33:57 11/29/2017 
-- Design Name: 
-- Module Name:    ALUMuxA - Behavioral 
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

entity ALUMuxA is
	port(
		--控制信号
		ForwardA : in std_logic_vector(1 downto 0);
		--供选择数据
		readData1 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- 上上条指令将写回的寄存器值(WriteData)
		--选择结果输出
		ALUSrcA : out std_logic_vector(15 downto 0)
	);
end ALUMuxA;

architecture Behavioral of ALUMuxA is
	
begin
	
	process(ForwardA, readData1, ExeMemALUResult, MemWbWriteData)
	begin
		case ForwardA is
			when "01" =>
				ALUSrcA <= ExeMemALUResult;
			when "10" =>
				ALUSrcA <= MemWbWriteData;
			when others =>
				ALUSrcA <= readData1;
		end case;
	end process;

end Behavioral;

