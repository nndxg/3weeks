----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:25:51 11/28/2017 
-- Design Name: 
-- Module Name:    Forwarding_unit - Behavioral 
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

entity Forwarding_unit is
	port(
		ExeMemWriteReg : in std_logic_vector(3 downto 0);   -- 上条指令写回的寄存器 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbWriteReg : in std_logic_vector(3 downto 0);    -- 上上条指令写回的寄存器 上上条指令的WriteData
		
		IdExeMemWrite : in std_logic;
		
		IdExeReadReg1 : in std_logic_vector(3 downto 0);  -- 本条指令的源寄存器1
		IdExeReadReg2 : in std_logic_vector(3 downto 0);  -- 本条指令的源寄存器2
		
		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0)	     -- 选择SW/SW_SP的WriteData
	);
end Forwarding_unit;

architecture Behavioral of Forwarding_unit is

begin

	process(ExeMemWriteReg, MemWbWriteReg, IdExeALUsrcB, IdExeMemWrite, IdExeReadReg1, IdExeRead2)
	begin
		if (IdExeReadReg1 = ExeMemWriteReg) then
			ForwardA <= "01";
		elsif (IdExeReadReg1 = MemWbWriteReg) then
			ForwardA <= "10";
		else
			ForwardA <= "00";
		end if;
		
		if (IdExeReadReg2 = ExeMemWriteReg) then
			ForwardB <= "01";
		elsif (IdExeReadReg2 = MemWbWriteReg) then
			ForwardB <= "10";
		else
			ForwardB <= "00";
		end if;
		
		if (IdExeMemWrite = '1') then
			if (IdExeReadReg2 = ExeMemWriteReg) then
				ForwardSW <= "01";
			elsif (IdExeReadReg2 = MemWbWriteReg) then
				ForwardSW <= "10";
			else
				ForwardSW <= "00";
		end if;

end Behavioral;

