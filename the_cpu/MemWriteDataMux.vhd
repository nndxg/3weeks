----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:31:10 11/29/2017 
-- Design Name: 
-- Module Name:    MemWriteDataMux - Behavioral 
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

entity MemWriteDataMux is
		port(
		--控制信号
		ForwardSW : in std_logic_vector(1 downto 0);
		--供选择数据
		readData2 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbResult : in std_logic_vector(15 downto 0);	   -- 上上条指令将写回的寄存器值(WriteData)
		--选择结果输出
		WriteData : out std_logic_vector(15 downto 0)
	);
end MemWriteDataMux;

architecture Behavioral of MemWriteDataMux is

begin

	process(ForwardSW, readData2, ExeMemALUResult, MemWbResult)
	begin
		case ForwardSW is
			when "01" =>
				WriteData <= ExeMemALUResult;
			when "10" =>
				WriteData <= MemWbResult;
			when others =>
				WriteData <= readData2;
		end case;
	end process;

end Behavioral;

