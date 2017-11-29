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
		--�����ź�
		ForwardSW : in std_logic_vector(1 downto 0);
		--��ѡ������
		readData2 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- ����ָ���ALU������ϸ�˵��MFPCMux�Ľ����
		MemWbResult : in std_logic_vector(15 downto 0);	   -- ������ָ�д�صļĴ���ֵ(WriteData)
		--ѡ�������
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

