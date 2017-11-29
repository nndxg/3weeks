----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:09:55 11/22/2017 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity Controller is
	port(
      rst : in  std_logic;
		command : in std_logic_vector(15 downto 0);
		controller : out std_logic_vector(20 downto 0)
		-- RegWrite(1) RegDst(3) RegSrc1(3) RegSrc2(1) 
		-- immeSelect(3) ALUSrcB(1) ALUOp(4) 
		-- MemRead(1) MemWrite(1) MemToReg(1) isJump(1) isMFPC(1)
	);
end Controller;

architecture Behavioral of Controller is

begin
	process(rst, command)
	begin
		if (rst = '0') then
			controller <= "000000000000000000000";
		else
			case command(15 downto 11) is
				when "00001" =>		--NOP
					controller <= "000000000000000000000";
					
				when "00010" =>		--B
					controller <= "000000001100101000000";
					
				when "00100" =>		--BEQZ
					controller <= "000000101010100100000";
					
				when "00101" =>		--BNEZ
					controller <= "000000101010101100000";
					
				when "00110" =>		
					case command(1 downto 0) is
						when "00" =>		--SLL
							controller <= "100101000111011000000";
						when "11" =>		--SRA
							controller <= "100101000111011100000";
						when others =>			--Error
							controller <= "000000000000000000000";
					end case;
					
				when "01000" =>		--ADDIU3
					controller <= "101000100011000100000";
					
				when "01001" =>		--ADDIU
					controller <= "100100101011000100000";
					
				when "01011" =>		--SLTUI
					controller <= "110000101001110100000";
								
				when "01100" =>
					case command(10 downto 8) is
						when "011" =>		--ADDSP
							controller <= "110110101011000100000";
						when "000" =>		--BTEQZ
							controller <= "000010001010100100000";
						when "001" =>		--BTNEZ
							controller <= "000010001010101100000";
						when "100" =>		--MTSP
							controller <= "110101000000111000000";
						when others =>			--Error
							controller <= "000000000000000000000";
					end case;
				
				when "01101" =>		--LI
					controller <= "100100001001111100000";
					
				when "01111" =>		--MOVE
					controller <= "100101000000111000000";
				
				when "10010" =>		--LW_SP
					controller <= "100110101011000110100";
					
				when "10011" =>		--LW
					controller <= "101000100101000110100";
				
				when "11010" =>		--SW_SP
					controller <= "000010101011000101000";
					
				when "11011" =>		--SW
					controller <= "000000110101000101000";
				
				when "11100" =>
					case command(1 downto 0) is
						when "01" =>		--ADDU
							controller <= "101100110000000100000";
						when "11" =>		--SUBU
							controller <= "101100110000001000000";
						when others =>			--Error
							controller <= "000000000000000000000";
					end case;
					
				when "11101" =>
					case command(4 downto 0) is
						when "01100" =>		--AND
							controller <= "100100110000001100000";
						when "01010" =>		--CMP
							controller <= "110000110000100000000";
						when "00000" =>		
							case command(7 downto 5) is
								when "000" =>	--JR
									controller <= "000000100000000000010";
								when "010" =>		--MFPC
									controller <= "100100000000000000001";
								when others =>			--Error
									controller <= "000000000000000000000";
							end case;
						when "01111" =>		--NOT
							controller <= "100101000000010100000";
						when "01101" =>		--OR
							controller <= "100100110000010000000";
						when "00110" =>		--SRLV
							controller <= "101001000000110000000";
						when others =>			--Error
							controller <= "000000000000000000000";
					end case;
									
				when "11110" =>		
					case command(7 downto 0) is
						when "00000000" =>		--MFIH
							controller <= "100111000000111000000";
						when "00000001" =>		--MTIH
							controller <= "111000100000111000000";
						when others =>			--Error
							controller <= "000000000000000000000";
					end case;
				
				when others =>			--Error
					controller <= "000000000000000000000";
			end case;
		end if;
	end process;

end Behavioral;

