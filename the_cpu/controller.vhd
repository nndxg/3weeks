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
		controller : out std_logic_vector(21 downto 0)
		-- RegWrite(1) RegDst(3) ReadReg1(3) ReadReg2(2) 
		-- immeSelect(3) ALUSrcBIsImme(1) ALUOp(4) 
		-- MemRead(1) MemWrite(1) WBSrc(1) isjump(1) isMFPC(1)
	);
end Controller;

architecture Behavioral of Controller is

begin
	process(rst, command)
	begin
		if (rst = '0') then
			controller <= "0000000000000000000000";
		else
			case command(15 downto 11) is
				when "00001" =>		--NOP
					controller <= "0000000000000000000000";
					
				when "00010" =>		--B
					controller <= "0000000001100101000000";
					
				when "00100" =>		--BEQZ
					controller <= "0000001001010100100000";
					
				when "00101" =>		--BNEZ
					controller <= "0000001001010101100000";
					
				when "00110" =>		
					case command(1 downto 0) is
						when "00" =>		--SLL
							controller <= "1001010000111011000000";
						when "11" =>		--SRA
							controller <= "1001010000111011100000";
						when others =>			--Error
							controller <= "0000000000000000000000";
					end case;
					
				when "01000" =>		--ADDIU3
					controller <= "1010001000011000100000";
					
				when "01001" =>		--ADDIU
					controller <= "1001001001011000100000";
					
				when "01011" =>		--SLTUI
					controller <= "1100001001001110100000";
								
				when "01100" =>
					case command(10 downto 8) is
						when "011" =>		--ADDSP
							controller <= "1101101001011000100000";
						when "000" =>		--BTEQZ
							controller <= "0000100001010100100000";
						when "001" =>		--BTNEZ
							controller <= "0000100001010101100000";
						when "100" =>		--MTSP
							controller <= "1101010000000111000000";
						when others =>			--Error
							controller <= "0000000000000000000000";
					end case;
				
				when "01101" =>		--LI
					controller <= "1001000001001111100000";
					
				when "01111" =>		--MOVE
					controller <= "1001010000000111000000";
				
				when "10010" =>		--LW_SP
					controller <= "1001101001011000110100";
					
				when "10011" =>		--LW
					controller <= "1010001000101000110100";
				
				when "11010" =>		--SW_SP
					controller <= "0000101101011000101000";
					
				when "11011" =>		--SW
					controller <= "0000001110101000101000";
				
				when "11100" =>
					case command(1 downto 0) is
						when "01" =>		--ADDU
							controller <= "1011001110000000100000";
						when "11" =>		--SUBU
							controller <= "1011001110000001000000";
						when others =>			--Error
							controller <= "0000000000000000000000";
					end case;
					
				when "11101" =>
					case command(4 downto 0) is
						when "01100" =>		--AND
							controller <= "1001001110000001100000";
						when "01010" =>		--CMP
							controller <= "1100001110000100000000";
						when "00000" =>		
							case command(7 downto 5) is
								when "000" =>	--JR
									controller <= "0000001000000000000010";
								when "010" =>		--MFPC
									controller <= "1001000000000000000001";
								when others =>			--Error
									controller <= "0000000000000000000000";
							end case;
						when "01111" =>		--NOT
							controller <= "1001010110000010100000";
						when "01101" =>		--OR
							controller <= "1001001110000010000000";
						when "00110" =>		--SRLV
							controller <= "1010010110000110000000";
						when others =>			--Error
							controller <= "0000000000000000000000";
					end case;
									
				when "11110" =>		
					case command(7 downto 0) is
						when "00000000" =>		--MFIH
							controller <= "1001110000000111000000";
						when "00000001" =>		--MTIH
							controller <= "1110001000000111000000";
						when others =>			--Error
							controller <= "0000000000000000000000";
					end case;
				
				when others =>			--Error
					controller <= "0000000000000000000000";
			end case;
		end if;
	end process;

end Behavioral;

