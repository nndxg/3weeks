----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:59:14 11/30/2017 
-- Design Name: 
-- Module Name:    IfIdRegisters - Behavioral 
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

entity IfIdRegisters is
	port(
		rst: in std_logic;
		clk: in std_logic;
		isJump: in std_logic;
		willBranch: in std_logic;
		IfIdFlush_StructConflict: in std_logic;
		IfIdKeep_LW: in std_logic;
		PCPlusOneIn: in std_logic_vector(15 downto 0);
		CommandIn: in std_logic_vector(15 downto 0);
		
		PCPlusOneOut: out std_logic_vector(15 downto 0);
		CommandOut: out std_logic_vector(15 downto 0);
		command10to8: out std_logic_vector(2 downto 0);
		command7to5: out std_logic_vector(2 downto 0);
		command4to2: out std_logic_vector(2 downto 0);
		command10to0: out std_logic_vector(10 downto 0)
	);
end IfIdRegisters;

architecture Behavioral of IfIdRegisters is

begin

	process(rst, clk)
	begin
	
		if (rst = '0') then
		
			PCPlusOneOut <=  (others => '0');
			CommandOut <= (others => '0');
			command10to8 <= (others => '0');
			command7to5 <= (others => '0');
			command4to2 <= (others => '0');
			command10to0 <= (others => '0');
			
		elsif (rising_edge(clk)) then
			
			if ((isJump = '1') or (willBranch = '1') or (IfIdFlush_StructConflict = '1')) then
			
				PCPlusOneOut <=  (others => '0');
				CommandOut <= (others => '0');
				command10to8 <= (others => '0');
				command7to5 <= (others => '0');
				command4to2 <= (others => '0');
				command10to0 <= (others => '0');
				
			elsif (IfIdKeep_LW = '0') then
				
				PCPlusOneOut <=  PCPlusOneIn;
				CommandOut <= CommandIn;
				command10to8 <= CommandIn(10 downto 8);
				command7to5 <= CommandIn(7 downto 5);
				command4to2 <= CommandIn(4 downto 2);
				command10to0 <= CommandIn(10 downto 0);
				
			end if;
		
		end if;
		
	end process;

end Behavioral;

