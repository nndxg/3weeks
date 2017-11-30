----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:22:21 11/29/2017 
-- Design Name: 
-- Module Name:    MFPCMux - Behavioral 
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

entity MFPCMux is
	--（MFPC指令）从PC+1和ALUResult中选择一个作为"真正的ALUResult" ???
	port(
		PCAddOne  : in std_logic_vector(15 downto 0);	
		RawALUResult : in std_logic_vector(15 downto 0); -- ALU计算结果
		isMFPC		 : in std_logic;		-- isMFPC = '1' 表示当前指令是MFPC，选择PC+1的值
		
		RealALUResult : out std_logic_vector(15 downto 0)
	);
end MFPCMux;

architecture Behavioral of MFPCMux is

begin
	
	process(PCAddOne, RawALUResult, isMFPC)
	begin
		if (isMFPC = '1') then
			RealALUResult <= PCAddOne;
		else
			RealALUResult <= RawALUResult;
		end if;
	end process;

end Behavioral;

