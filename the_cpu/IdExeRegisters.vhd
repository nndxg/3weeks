----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:19:47 11/30/2017 
-- Design Name: 
-- Module Name:    IdExeRegisters - Behavioral 
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

entity IdExeRegisters is
	port(
		rst : in std_logic;
		clk : in std_logic;
		IdExeFlush_LW : in std_logic;		            --LW数据冲突用
		IdExeFlush_StructConflict : in std_logic;		--SW结构冲突用
		
		RegWriteIn : in std_logic;
		WBSrcIn : in std_logic;
		MemWriteIn : in std_logic;
		MemReadIn : in std_logic;
		isMFPCIn : in std_logic;
		isJumpIn : in std_logic;
		ALUOpIn : in std_logic_vector(3 downto 0);
		ALUSrcBIn : in std_logic;
		
		PCPlusOneIn : in std_logic_vector(15 downto 0);
		ReadReg1In : in std_logic_vector(3 downto 0);		
		ReadReg2In : in std_logic_vector(3 downto 0);
		ReadData1In : in std_logic_vector(15 downto 0);	
		ReadData2In : in std_logic_vector(15 downto 0);			
		ImmeIn : in std_logic_vector(15 downto 0);	
		WriteRegIn : in std_logic_vector(3 downto 0);
		
		
		RegWriteOut : out std_logic;
		WBSrcOut : out std_logic;
		MemWriteOut : out std_logic;
		MemReadOut : out std_logic;
		isMFPCOut : out std_logic;
		isJumpOut : out std_logic;
		ALUOpOut : out std_logic_vector(3 downto 0);
		ALUSrcBOut : out std_logic;
		
		PCPlusOneOut : out std_logic_vector(15 downto 0);
		ReadReg1Out : out std_logic_vector(3 downto 0);		
		ReadReg2Out : out std_logic_vector(3 downto 0);
		ReadData1Out : out std_logic_vector(15 downto 0);	
		ReadData2Out : out std_logic_vector(15 downto 0);			
		ImmeOut : out std_logic_vector(15 downto 0);	
		WriteRegOut : out std_logic_vector(3 downto 0)
	);
end IdExeRegisters;

architecture Behavioral of IdExeRegisters is

begin

	process(rst, clk)
	begin
		if (rst = '0') then
		
			RegWriteOut <= '0';
			WBSrcOut <= '0';
			MemWriteOut <= '0';
			MemReadOut <= '0';
			isMFPCOut <= '0';
			isJumpOut <= '0';
			ALUOpOut <= "0000";
			ALUSrcBOut <= '0';
		
			PCPlusOneOut <= (others => '0');
			ReadReg1Out <= "1111";		
			ReadReg2Out <= "1111";
			ReadData1Out <= (others => '0');	
			ReadData2Out <= (others => '0');			
			ImmeOut : <= (others => '0');	
			WriteRegOut <= "1110";
			
		elsif (rising_edge(clk)) then
			
			if ((IdExeFlush_LW = '1') or (IdExeFlush_StructConflict = '1')) then
				
				RegWriteOut <= '0';
				WBSrcOut <= '0';
				MemWriteOut <= '0';
				MemReadOut <= '0';
				isMFPCOut <= '0';
				isJumpOut <= '0';
				ALUOpOut <= "0000";
				ALUSrcBOut <= '0';
		
				PCPlusOneOut <= (others => '0');
				ReadReg1Out <= "1111";		
				ReadReg2Out <= "1111";
				ReadData1Out <= (others => '0');	
				ReadData2Out <= (others => '0');			
				ImmeOut : <= (others => '0');	
				WriteRegOut <= "1110";
				
			else
				
				RegWriteOut <= RegWriteIn;
				WBSrcOut <= WBSrcIn;
				MemWriteOut <= MemWriteIn;
				MemReadOut <= MemReadIn;
				isMFPCOut <= isMFPCIn;
				isJumpOut <= isJumpIn;
				ALUOpOut <= ALUOpIn;
				ALUSrcBOut <= ALUSrcBIn;
		
				PCPlusOneOut <= PCPlusOneIn;
				ReadReg1Out <= ReadReg1In;		
				ReadReg2Out <= ReadReg2In;
				ReadData1Out <= ReadData1In;	
				ReadData2Out <= ReadData2In;			
				ImmeOut : <= ImmeIn;	
				WriteRegOut <= WriteRegIn;
				
			end if;
		end if;
	end process;
				
end Behavioral;

