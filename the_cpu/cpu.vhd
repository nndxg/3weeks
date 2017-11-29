----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:33:14 11/27/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
	port(
			rst : in std_logic; --reset
			clk_hand : in std_logic; --时钟源  默认为50M  可以通过修改绑定管脚来改变
			clk_50 : in std_logic;
			opt : in std_logic;	--选择输入时钟（为手动或者50M）
			
			
			--串口
			dataReady : in std_logic;   
			tbre : in std_logic;
			tsre : in std_logic;
			rdn : inout std_logic;
			wrn : inout std_logic;
			
			--RAM1  存放数据
			ram1En : out std_logic;
			ram1We : out std_logic;
			ram1Oe : out std_logic;
			ram1Data : inout std_logic_vector(15 downto 0);
			ram1Addr : out std_logic_vector(17 downto 0);
			
			--RAM2 存放程序和指令
			ram2En : out std_logic;
			ram2We : out std_logic;
			ram2Oe : out std_logic;
			ram2Data : inout std_logic_vector(15 downto 0);
			ram2Addr : out std_logic_vector(17 downto 0);
			
			--debug  digit1、digit2显示PC值，led显示当前指令的编码
			digit1 : out std_logic_vector(6 downto 0);	--7位数码管1
			digit2 : out std_logic_vector(6 downto 0);	--7位数码管2
			led : out std_logic_vector(15 downto 0);
			
			hs,vs : out std_logic;
			redOut, greenOut, blueOut : out std_logic_vector(2 downto 0)
	);
end cpu;

architecture Behavioral of cpu is
	component Memory_unit
	port(
		--时钟
		clk : in std_logic;
		rst : in std_logic;
		
		--RAM1（串口）
		data_ready : in std_logic;		--数据准备信号，='1'表示串口的数据已准备好（读串口成功，可显示读到的data）
		tbre : in std_logic;				--发送数据标志
		tsre : in std_logic;				--数据发送完毕标志，tsre and tbre = '1'时写串口完毕
		wrn : out std_logic;				--写串口，初始化为'1'，先置为'0'并把RAM1data赋好，再置为'1'写串口
		rdn : out std_logic;				--读串口，初始化为'1'并将RAM1data赋为"ZZ..Z"，
												--若data_ready='1'，则把rdn置为'0'即可读串口（读出数据在RAM1data上）
		
		--RAM2（IM+DM）
		MemRead : in std_logic;							--控制读DM的信号，='1'代表需要读
		MemWrite : in std_logic;						--控制写DM的信号，='1'代表需要写
		
		dataIn : in std_logic_vector(15 downto 0);		--写内存时，要写入DM或IM的数据
		
		ramAddr : in std_logic_vector(15 downto 0);		--读DM/写DM/写IM时，地址输入
		PCOut : in std_logic_vector(15 downto 0);		--读IM时，地址输入
		PCMuxOut : in std_logic_vector(15 downto 0);	
		PCKeep : in std_logic;
		
		dataOut : out std_logic_vector(15 downto 0);	--读DM时，读出来的数据/读出的串口状态
		insOut : out std_logic_vector(15 downto 0);		--读IM时，出来的指令
		
		ram1_addr : out std_logic_vector(17 downto 0); 	--RAM1地址总线
		ram2_addr : out std_logic_vector(17 downto 0); 	--RAM2地址总线
		ram1_data : inout std_logic_vector(15 downto 0);--RAM1数据总线
		ram2_data : inout std_logic_vector(15 downto 0);--RAM2数据总线
		
		ram2AddrOutput : out std_logic_vector(17 downto 0);
		
		ram1_en : out std_logic;		--RAM1使能，='1'禁止，永远等于'1'
		ram1_oe : out std_logic;		--RAM1读使能，='1'禁止，永远等于'1'
		ram1_we : out std_logic;		--RAM1写使能，='1'禁止，永远等于'1'
		
		ram2_en : out std_logic;		--RAM2使能，='1'禁止，永远等于'0'
		ram2_oe : out std_logic;		--RAM2读使能，='1'禁止
		ram2_we : out std_logic		--RAM2写使能，='1'禁止		
		
	);
	end component;
	
	component imme_unit
	port(
				 Im_in : in std_logic_vector(10 downto 0);
				 Im_select : in std_logic_vector(2 downto 0);			 
				 Im_out : out std_logic_vector(15 downto 0)
			);
	end component;
	
	component ReadReg1MUX
		port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);			--R0~R7中的一个
			
			contro : in std_logic_vector(2 downto 0);		--由总控制器Controller生成的控制信号
			
			ReadReg1Out : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1111"=没有
		);
	end component;
	
	component ReadReg2MUX
		port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			
			contro : in std_logic_vector(1 downto 0);
			
			ReadReg2Out : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1111"=没有
		);
	end component;
	
	component ReadDstMUX
		port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			four_downto_two : in std_logic_vector(2 downto 0);
			contro : in std_logic_vector(2 downto 0);
			
			ReadDstOut : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1110"=没有
		);
	end component;
	
	component Registers
		Port(
			clk:in std_logic;
			rst:in std_logic;
			RegWrite:in std_logic;
			readReg1:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T
			readReg2:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7
			WriteReg:in std_logic_vector(3 downto 0);--"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T
			WriteData:in std_logic_vector(15 downto 0);
			readData1:out std_logic_vector(15 downto 0);
			readData2:out std_logic_vector(15 downto 0)
	);
	end component;
	
	component ALU
		Port(
			input1:in STD_LOGIC_VECTOR(15 downto 0);
			input2:in STD_LOGIC_VECTOR(15 downto 0);
			contro:in STD_LOGIC_VECTOR(3 downto 0);
			result:out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
			branch:out STD_LOGIC
		);
	end component;
	
	component Controller
		port(
			rst : in  std_logic;
			command : in std_logic_vector(15 downto 0);
			controller : out std_logic_vector(21 downto 0)
			-- RegWrite(1) RegDst(3) ReadReg1(3) ReadReg2(2) 
			-- immeSelect(3) ALUSrcB(1) ALUOp(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1) jump(1) MFPC(1)
		);
	end component;
	
	--Memory_unit （有一大部分都已在cpu的port里体现）
	signal DataOut : std_logic_vector(15 downto 0);
	signal InsOut : std_logic_vector(15 downto 0);
	
	--ReadDstMUX
	signal ReadDstOut : std_logic_vector(3 downto 0);
	
	--controller
	signal controller : std_logic_vector(20 downto 0);
	
	--Registers
	signal ReadData1, ReadData2 : std_logic_vector(15 downto 0);
	
	--ImmExtend
	signal Im_out : std_logic_vector(15 downto 0);
	
	--ALU
	signal result : std_logic_vector(15 downto 0);
	signal branch : std_logic;
	
	--ReadReg1MUX
	signal ReadReg1Out : std_logic_vector(3 downto 0);
	
	--ReadReg2MUX
	signal ReadReg2Out : std_logic_vector(3 downto 0);
	
begin
	u17 : Memory_unit
		port map( 
			clk => clk,
         rst => rst,
			
			data_ready => dataReady,
			tbre => tbre,
			tsre => tsre,
         wrn => wrn,
			rdn => rdn,
			  
			MemRead => ExMemRead,
			MemWrite => ExMemWrite,
			
			dataIn => ExMemReadData2,
			
			ramAddr => ExMemALUResult,
			PCOut => PCOut,
			PCMuxOut => PCMuxOut,
			PCKeep => PCKeep,
			dataOut => DataOut,
			insOut => InsOut,
			
			ram1_addr => ram1Addr,
			ram2_addr => ram2Addr,
			ram1_data => ram1Data,
			ram2_data => ram2Data,
			
			ram2AddrOutput => ram2AddrOutput,
			
			ram1_en => ram1En,
			ram1_oe => ram1Oe,
			ram1_we => ram1We,
			ram2_en => ram2En,
			ram2_oe => ram2Oe,
			ram2_we => ram2We
		);

	u4 : ReadDstMUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			four_downto_two => four_downto_two,
			
			contro => controller(20 downto 18),
			ReadDstOut => ReadDstOut
		);
		
	u5 : Controller
	port map(	
			command => IfIdCommand,
			rst => rst,
			controller => controller
			-- RegWrite(21) RegDst(20-18) ReadReg1(17-15) ReadReg2(14-13) 
			-- immeSelect(12-10) ALUSrcB(9) ALUOp(8-5) 
			-- MemRead(4) MemWrite(3) MemToReg(2) jump(1) MFPC(0)
		);
		
	u6 : Registers
	port map(
			clk => clk,
			rst => rst,
			
			readReg1 => ReadReg1Out,
			readReg2 => ReadReg2Out,
			
			--这三条来自MEM/WB段寄存器（因为发生在写回段）
			WriteReg => rdToWB,
			WriteData => dataToWB,
			contro => MemWbRegWrite,
			
			readData1 => readData1,
			readData2 => readData2
		);
		
	u7 : imme_unit
	port map(
			 Im_in => imme_10_0,
			 Im_select => controller(12 downto 10),
			 
			 Im_out => extendedImme
		);
	
	u12 : ALU
	port map(
			input1      	=> AMuxOut,
			input2        => BMuxOut,
			contro		  	=> IdExALUOP,
			
			result  	=> result,
			branch => branch
	);
	
	u21 : ReadReg1MUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			contro => controller(17 downto 15),
			
			ReadReg1Out => ReadReg1MuxOut
	);
	
	u22 : ReadReg2MUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			contro => controller(14 downto 13),
			
			ReadReg2Out => ReadReg2MuxOut

	);


end Behavioral;

