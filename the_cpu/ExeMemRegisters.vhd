----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:41:16 11/30/2017 
-- Design Name: 
-- Module Name:    ExeMemRegisters - Behavioral 
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

entity ExeMemRegisters is
	port(
		rst: in std_logic;
		clk: in std_logic;
		IdExeRegWrite: in std_logic;
		IdExeWBSrc: in std_logic;
		IdExeMemRead: in std_logic;
		IdExeMemWrite: in std_logic;
		RealALUResultIn: in std_logic_vector(15 downto 0);
		MemWriteDataIn: in std_logic_vector(15 downto 0);
		IdExeWriteReg: in std_logic_vector(3 downto 0);
		
		ExeMemRegWrite: out std_logic;
		ExeMemWBSrc: out std_logic;
		ExeMemMemRead: out std_logic;
		ExeMemMemWrite: out std_logic;
		ALUResultOut: out std_logic_vector(15 downto 0);
		MemWriteDataOut: out std_logic_vector(15 downto 0);
		ExeMemWriteReg: out std_logic_vector(3 downto 0)
	);
end ExeMemRegisters;

architecture Behavioral of ExeMemRegisters is

begin

	process(rst, clk)
	begin
		if (rst = '0') then
			ExeMemRegWrite <= '0';
			ExeMemWBSrc <= '0';
			ExeMemMemRead <= '0';
			ExeMemMemWrite <= '0';
			ALUResultOut <= (others => '0');
			MemWriteDataOut <= (others => '0');
			ExeMemWriteReg <= "1110";
		elsif (rising_edge(clk)) then
			ExeMemRegWrite <= IdExeRegWrite;
			ExeMemWBSrc <= IdExeWBSrc;
			ExeMemMemRead <= IdExeMemRead;
			ExeMemMemWrite <= IdExeMemWrite;
			ALUResultOut <= RealALUResultIn;
			MemWriteDataOut <= MemWriteDataIn;
			ExeMemWriteReg <= IdExeWriteReg;
		end if;
	end process;

end Behavioral;

