--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:18:53 12/01/2017
-- Design Name:   
-- Module Name:   C:/Users/nuonuo/Desktop/3weeks_in/3weeks/the_cpu/test.vhd
-- Project Name:  the_cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         input1 : IN  std_logic_vector(15 downto 0);
         input2 : IN  std_logic_vector(15 downto 0);
         contro : IN  std_logic_vector(3 downto 0);
         result : OUT  std_logic_vector(15 downto 0);
         branch : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal input1 : std_logic_vector(15 downto 0) := (others => '0');
   signal input2 : std_logic_vector(15 downto 0) := (others => '0');
   signal contro : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal result : std_logic_vector(15 downto 0);
   signal branch : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          input1 => input1,
          input2 => input2,
          contro => contro,
          result => result,
          branch => branch
        );

   -- Clock process definitions
   <clock>_process :process
   begin
		<clock> <= '0';
		wait for 10ns;
		<clock> <= '1';
		wait for 10ns;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
