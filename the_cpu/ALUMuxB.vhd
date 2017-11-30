----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:35:48 11/29/2017 
-- Design Name: 
-- Module Name:    ALUMuxB - Behavioral 
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

entity ALUMuxB is
	port(
		--控制信号
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrcBIsImme  : in std_logic;
		--供选择数据
		readData2 : in std_logic_vector(15 downto 0);
		imme 	    : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- 上上条指令（包括插入的NOP）将写回的寄存器值(WriteData)
		--选择结果输出
		ALUSrcB : out std_logic_vector(15 downto 0)
	);	
end ALUMuxB;

architecture Behavioral of ALUMuxB is
begin

	process(ForwardB, readData2, ExeMemALUResult, MemWbWriteData)
	begin
		if (ALUSrcBIsImme = '1') then
			ALUSrcB <= imme;
		else
			case ForwardB is
				when "01" =>
					ALUSrcB <= ExeMemALUResult;
				when "10" =>
					ALUSrcB <= MemWbWriteData;
				when others =>
					ALUSrcB <= readData2;
			end case;
		end if;
	end process;

end Behavioral;

