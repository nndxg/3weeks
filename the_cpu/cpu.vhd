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
			clk : in std_logic;
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
			-- immeSelect(3) ALUSrcBIsImme(1) ALUOp(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1) jump(1) MFPC(1)
		);
	end component;
	
	component ALUMuxA
	port(
		--控制信号
		ForwardA : in std_logic_vector(1 downto 0);
		--供选择数据
		readData1 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- 上上条指令（包括插入的NOP）将写回的寄存器值(WriteData)
		--选择结果输出
		ALUSrcA : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--选择器：ALU的第二个计算数
	component ALUMuxB
	port(
		--控制信号
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrcBIsImme  : in std_logic;
		--供选择数据
		readData2 : in std_logic_vector(15 downto 0);
		imme 	    : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- 上上条指令（包括插入的NOP）将写回的寄存器值(WriteData)
		--选择结果输出
		ALUSrcB : out std_logic_vector(15 downto 0)
	);	
	end component;
	
	component PCMux
	port(
		PCPlusOne: in std_logic_vector(15 downto 0);
		ALUResult: in std_logic_vector(15 downto 0);
		PCAfterBranch: in std_logic_vector(15 downto 0);
		isJump: in std_logic;
		willBranch: in std_logic;
		PCRollBack: in std_logic;
		
		selectedPC: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component MFPCMux
	--（MFPC指令）从PC+1和ALUResult中选择一个作为"真正的ALUResult" ???
	port(
		PCAddOne  : in std_logic_vector(15 downto 0);	
		RawALUResult : in std_logic_vector(15 downto 0); -- ALU计算结果
		isMFPC		 : in std_logic;		-- isMFPC = '1' 表示当前指令是MFPC，选择PC+1的值
		
		RealALUResult : out std_logic_vector(15 downto 0)
	);
	end component;
	
	component ExeMemRegisters
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
	end component;
	
	component Forwarding_unit
	port(
		ExeMemWriteReg : in std_logic_vector(3 downto 0);   -- 上条指令写回的寄存器 
		MemWbWriteReg : in std_logic_vector(3 downto 0);    -- 上上条指令写回的寄存器 
		
		IdExeMemWrite : in std_logic;
		
		IdExeReadReg1 : in std_logic_vector(3 downto 0);  -- 本条指令的源寄存器1
		IdExeReadReg2 : in std_logic_vector(3 downto 0);  -- 本条指令的源寄存器2
		
		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0)	     -- 选择SW/SW_SP的WriteData
	);
	end component;
	
	component HazardDetectionUnit
	port(
		IdExeMemRead: in std_logic;
		IdExeWriteReg: in std_logic_vector(3 downto 0);
		readReg1: in std_logic_vector(3 downto 0);
		readReg2: in std_logic_vector(3 downto 0);
		
		IdExeFlush_LW: out std_logic;
		PCKeep: out std_logic;
		IfIdKeep_LW: out std_logic
	);
	end component;
	
	component IdExeRegisters
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
		ALUSrcBIsImmeIn : in std_logic;
		
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
		ALUSrcBIsImmeOut : out std_logic;
		
		PCPlusOneOut : out std_logic_vector(15 downto 0);
		ReadReg1Out : out std_logic_vector(3 downto 0);		
		ReadReg2Out : out std_logic_vector(3 downto 0);
		ReadData1Out : out std_logic_vector(15 downto 0);	
		ReadData2Out : out std_logic_vector(15 downto 0);			
		ImmeOut : out std_logic_vector(15 downto 0);	
		WriteRegOut : out std_logic_vector(3 downto 0)
	);
	end component;
	
	component IfIdRegisters
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
	end component;
	
	component MemWbRegisters
		port(
		rst: in std_logic;
		clk: in std_logic;
		ExeMemRegWrite: in std_logic;
		ExeMemWBSrc: in std_logic;
		MemReadData: in std_logic_vector(15 downto 0);
		ALUResult: in std_logic_vector(15 downto 0);
		ExeMemWriteReg: in std_logic_vector(3 downto 0);
		
		MemWbRegWrite: out std_logic;
		MemWbWriteReg: out std_logic_vector(3 downto 0);
		WriteData: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component MemWriteDataMux
		port(
		--控制信号
		ForwardSW : in std_logic_vector(1 downto 0);
		--供选择数据
		readData2 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- 上条指令的ALU结果（严格说是MFPCMux的结果）
		MemWbResult : in std_logic_vector(15 downto 0);	   -- 上上条指令（包括插入的NOP）将写回的寄存器值(WriteData)
		--选择结果输出
		WriteData : out std_logic_vector(15 downto 0)
	);
	end component;
	
	component PCBrancherAdder
		port(
			PCPlusOne: in std_logic_vector(15 downto 0);
			IdExeImme: in std_logic_vector(15 downto 0);
			PCAfterBranch: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component PCIncrementer
	port(
		PCin: in std_logic_vector(15 downto 0);
		PCPlusOne: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component PCRegister
	port(
		rst: in std_logic;
		clk: in std_logic;
		PCKeep: in std_logic;
		selectedPC: in std_logic_vector(15 downto 0);
		nextPC: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component StructConflictUnit
	port(
		IdExeMemWrite: in std_logic;
		ALUResult: in std_logic_vector(15 downto 0);
		IfIdFlush_StructConflict: out std_logic;
		IdExeFlush_StructConflict: out std_logic;
		PCRollBack: out std_logic
	);
	end component;
	
	
	--Memory_unit （有一大部分都已在cpu的port里体现）
	signal DataOut : std_logic_vector(15 downto 0);
	signal InsOut : std_logic_vector(15 downto 0);
	
	--ReadDstMUX
	signal ReadDstOut : std_logic_vector(3 downto 0);
	
	--controller
	signal controllerOut : std_logic_vector(21 downto 0);
	
	--Registers
	signal RegReadData1Out, RegReadData2Out : std_logic_vector(15 downto 0);
	
	--ImmExtend
	signal Im_out : std_logic_vector(15 downto 0);
	
	--ALU
	signal ALUresultOut : std_logic_vector(15 downto 0);
	signal branchOut : std_logic;
	
	--ReadReg1MUX
	signal ReadReg1MUXOut : std_logic_vector(3 downto 0);
	
	--ReadReg2MUX
	signal ReadReg2MUXOut : std_logic_vector(3 downto 0);
	
	--ALUMuxA
	signal ALUSrcAOut : std_logic_vector(15 downto 0);
	
	--ALUMuxB
	signal ALUSrcBOut : std_logic_vector(15 downto 0);
	
	--ExeMemRegisters
	signal ExeMemRegWriteOut : std_logic;
	signal ExeMemWBSrcOut: std_logic;
	signal ExeMemMemReadOut: std_logic;
	signal ExeMemMemWriteOut: std_logic;
	signal ExeMemALUResultOut: std_logic_vector(15 downto 0);
	signal ExeMemMemWriteDataOut: std_logic_vector(15 downto 0);
	signal ExeMemWriteRegOut: std_logic_vector(3 downto 0);
	
	--Forwarding_unit
	signal ForwardAOut : std_logic_vector(1 downto 0);
	signal ForwardBOut : std_logic_vector(1 downto 0);
	signal ForwardSWOut : std_logic_vector(1 downto 0);
	
	--HazardDetectionUnit
	signal IdExeFlush_LWOut: std_logic;
	signal PCKeepOut: std_logic;
	signal IfIdKeep_LWOut: std_logic;
	
	--IdExeRegisters
	signal IdExeRegWriteOut : std_logic;
	signal IdExeWBSrcOut : std_logic;
	signal IdExeMemWriteOut : std_logic;
	signal IdExeMemReadOut : std_logic;
	signal isMFPCOut : std_logic;
	signal isJumpOut : std_logic;
	signal IdExeALUOpOut : std_logic_vector(3 downto 0);
	signal IdExeALUSrcBIsImmeOut : std_logic;
		
	signal IdExePCPlusOneOut : std_logic_vector(15 downto 0);
	signal IdExeReadReg1Out : std_logic_vector(3 downto 0);		
	signal IdExeReadReg2Out : std_logic_vector(3 downto 0);
	signal IdExeReadData1Out : std_logic_vector(15 downto 0);	
	signal IdExeReadData2Out : std_logic_vector(15 downto 0);			
	signal IdExeImmeOut : std_logic_vector(15 downto 0);	
	signal IdExeWriteRegOut : std_logic_vector(3 downto 0);
	
	--IfIdRegisters
	signal IfIdPCPlusOneOut: std_logic_vector(15 downto 0);
	signal CommandOut: std_logic_vector(15 downto 0);
	signal command10to8Out: std_logic_vector(2 downto 0);
	signal command7to5Out: std_logic_vector(2 downto 0);
	signal command4to2Out: std_logic_vector(2 downto 0);
	signal command10to0Out: std_logic_vector(10 downto 0);
	
	--MFPCMux
	signal RealALUResultOut : std_logic_vector(15 downto 0);
	
	--MemWbRegisters
	signal MemWbRegWriteOut: std_logic;
	signal MemWbWriteRegOut: std_logic_vector(3 downto 0);
	signal MemWbResultOut: std_logic_vector(15 downto 0);
	
	--MemWriteDataMux
	signal MUXWriteDataOut : std_logic_vector(15 downto 0);
	
	--PCBrancherAdder
	signal PCAfterBranchOut: std_logic_vector(15 downto 0);
	
	--PCIncrementer
	signal PCPlusOneOut: std_logic_vector(15 downto 0);
	
	--PCMux
	signal selectedPCOut: std_logic_vector(15 downto 0);
	
	--PCRegister
	signal nextPCOut: std_logic_vector(15 downto 0);
	
	--StructConflictUnit
	signal IfIdFlush_StructConflictOut: std_logic;
	signal IdExeFlush_StructConflictOut: std_logic;
	signal PCRollBackOut: std_logic;
	
begin
	u1 : ALUMuxA
	port map(
			ForwardA => ForwardAOut,
			readData1 => IdExeReadData1Out,
			ExeMemALUResult => ExeMemALUResultOut,
			MemWbWriteData => MemWbResultOut,

			ALUSrcA => ALUSrcAOut
		);
		
	u2 : ALUMuxB
	port map(
			ForwardB => ForwardBOut,
			readData2 => IdExeReadData2Out,
			ExeMemALUResult => ExeMemALUResultOut,
			MemWbWriteData => MemWbResultOut,
			imme => IdExeImmeOut,

			ALUSrcB => ALUSrcBOut,
			ALUSrcBIsImme => IdExeALUSrcBIsImmeOut
		);
	
	u3 : ExeMemRegisters
	
	port map(
			rst => rst,
			clk => clk,
			IdExeRegWrite => IdExeRegWriteOut,
			IdExeWBSrc => IdExeWBSrcOut,
			IdExeMemRead => IdExeMemReadOut,
			IdExeMemWrite => IdExeMemWriteOut,
			RealALUResultIn => RealALUResultOut,
			MemWriteDataIn => MUXWriteDataOut,
			IdExeWriteReg => IdExeWriteRegOut,

			ExeMemRegWrite => ExeMemRegWriteOut,
			ExeMemWBSrc => ExeMemWBSrcOut,
			ExeMemMemRead => ExeMemMemReadOut,
			ExeMemMemWrite => ExeMemMemWriteOut,
			ALUResultOut => ExeMemALUResultOut,
			MemWriteDataOut => ExeMemMemWriteDataOut,
			ExeMemWriteReg => ExeMemWriteRegOut
		);
		
	u4 : Forwarding_unit
	port map(
			ExeMemWriteReg => ExeMemWriteRegOut,
			MemWbWriteReg => MemWbWriteRegOut,
			IdExeMemWrite => IdExeMemWriteOut,
			IdExeReadReg1 => IdExeReadReg1Out,
			IdExeReadReg2 => IdExeReadReg2Out,

			ForwardA => ForwardAOut,
			ForwardB => ForwardBOut,
			ForwardSW => ForwardSWOut
		);
		
	u5 : HazardDetectionUnit
	port map(
			IdExeMemRead => IdExeMemReadOut,
			IdExeWriteReg => IdExeWriteRegOut,
			readReg1 => ReadReg1MUXOut,
			readReg2 => ReadReg2MUXOut,

			IdExeFlush_LW => IdExeFlush_LWOut,
			PCKeep => PCKeepOut,
			IfIdKeep_LW => IfIdKeep_LWOut
		);
		
	u6 : IdExeRegisters
	
	port map(
			rst => rst,
			clk => clk,
			IdExeFlush_LW => IdExeFlush_LWOut,
			IdExeFlush_StructConflict => IdExeFlush_StructConflictOut,
			RegWriteIn => controllerOut(21),
			WBSrcIn => controllerOut(2),
			MemWriteIn => controllerOut(3),
			MemReadIn => controllerOut(4),
			isMFPCIn => controllerOut(0),
			isJumpIn => controllerOut(1),
			ALUOpIn => controllerOut(8 downto 5),
			ALUSrcBIsImmeIn => controllerOut(9),
			PCPlusOneIn => IfIdPCPlusOneOut,
			ReadReg1In => ReadReg1MUXOut,
			ReadReg2In => ReadReg2MUXOut,
			ReadData1In => RegReadData1Out,
			ReadData2In => RegReadData2Out,
			ImmeIn => Im_out,
			WriteRegIn => ReadDstOut,

			RegWriteOut => IdExeRegWriteOut,
			WBSrcOut => IdExeWBSrcOut,
			MemWriteOut => IdExeMemWriteOut,
			MemReadOut => IdExeMemReadOut,
			isMFPCOut => isMFPCOut,
			isJumpOut => isJumpOut,
			ALUOpOut => IdExeALUOpOut,
			ALUSrcBIsImmeOut => IdExeALUSrcBIsImmeOut,
			PCPlusOneOut => IdExePCPlusOneOut,
			ReadReg1Out => IdExeReadReg1Out,
			ReadReg2Out => IdExeReadReg2Out,
			ReadData1Out => IdExeReadData1Out,
			ReadData2Out => IdExeReadData2Out,
			ImmeOut => IdExeImmeOut,
			WriteRegOut => IdExeWriteRegOut
		);
	
	u7 : IfIdRegisters
	port map(
			rst => rst,
			clk => clk,
			isJump => isJumpOut,
			willBranch => branchOut,
			IfIdFlush_StructConflict => IfIdFlush_StructConflictOut,
			IfIdKeep_LW => IfIdKeep_LWOut,
			PCPlusOneIn => PCPlusOneOut,
			CommandIn => InsOut,

			PCPlusOneOut => IfIdPCPlusOneOut,
			CommandOut => CommandOut,
			command10to8 => command10to8Out,
			command7to5 => command7to5Out,
			command4to2 => command4to2Out,
			command10to0 => command10to0Out
		);
	
	u8 : MFPCMux
	port map(
			PCAddOne => IdExePCPlusOneOut,
			RawALUResult => ALUresultOut,
			isMFPC => isMFPCOut,

			RealALUResult => RealALUResultOut
		);
	
	u9 : MemWbRegisters
	port map(
			rst => rst,
			clk => clk,
			ExeMemRegWrite => ExeMemRegWriteOut,
			ExeMemWBSrc => ExeMemWBSrcOut,
			ExeMemWriteReg => ExeMemWriteRegOut,
			MemReadData => DataOut,
			ALUResult => RealALUResultOut,

			MemWbRegWrite => MemWbRegWriteOut,
			MemWbWriteReg => MemWbWriteRegOut,
			WriteData => MemWbResultOut
		);
		
	u10 : MemWriteDataMux
	port map(
			ForwardSW => ForwardSWOut,
			ExeMemALUResult => ExeMemALUResultOut,
			readData2 => IdExeReadData2Out,
			MemWbResult => MemWbResultOut,

			WriteData => MUXWriteDataOut
		);
		
	u11 : PCBrancherAdder
	port map(
			PCPlusOne => IdExePCPlusOneOut,
			IdExeImme => IdExeImmeOut,

			PCAfterBranch => PCAfterBranchOut
		);
		
	u12 : PCIncrementer
	port map(
			
			PCin => nextPCOut,

			PCPlusOne => PCPlusOneOut
		);
		
	u13 : PCMux
	port map(
			
			PCPlusOne => PCPlusOneOut,
			ALUResult => ALUresultOut,
			PCAfterBranch => PCAfterBranchOut,
			isJump => isJumpOut,
			willBranch => branchOut,
			PCRollBack => PCRollBackOut,

			selectedPC => selectedPCOut
		);
		
	u14 : PCRegister
	port map(
			
			clk => clk,
			rst => rst,
			PCKeep => PCKeepOut,
			selectedPC => selectedPCOut,

			nextPC => nextPCOut
		);
	
	u15 : StructConflictUnit
	port map(
			
			IdExeMemWrite => IdExeMemWriteOut,
			ALUResult => ALUresultOut,

			IfIdFlush_StructConflict => IfIdFlush_StructConflictOut,
			IdExeFlush_StructConflict => IdExeFlush_StructConflictOut,
			PCRollBack => PCRollBackOut
		);
	
	u16 : Memory_unit
		port map( 
			clk => clk,
         rst => rst,
			
			data_ready => dataReady,
			tbre => tbre,
			tsre => tsre,
         wrn => wrn,
			rdn => rdn,
			
			MemRead => ExeMemMemReadOut,
			MemWrite => ExeMemMemWriteOut,			
			dataIn => ExeMemMemWriteDataOut,			
			ramAddr => ExeMemALUResultOut,
			PCOut => nextPCOut,
			PCMuxOut => selectedPCOut,
			PCKeep => PCKeepOut,
			
			dataOut => DataOut,
			insOut => InsOut,
			
			ram1_addr => ram1Addr,
			ram2_addr => ram2Addr,
			ram1_data => ram1Data,
			ram2_data => ram2Data,
			
			ram1_en => ram1En,
			ram1_oe => ram1Oe,
			ram1_we => ram1We,
			ram2_en => ram2En,
			ram2_oe => ram2Oe,
			ram2_we => ram2We
		);

	u17 : ReadDstMUX	
	port map(
			ten_downto_eight => command10to8Out,
			seven_downto_five => command7to5Out,
			four_downto_two => command4to2Out,
			
			contro => controllerOut(20 downto 18),
			ReadDstOut => ReadDstOut
		);
		
	u18 : Controller
	port map(	
			command => CommandOut,
			rst => rst,
			controller => controllerOut
			-- RegWrite(21) RegDst(20-18) ReadReg1(17-15) ReadReg2(14-13) 
			-- immeSelect(12-10) ALUSrcBIsImme(9) ALUOp(8-5) 
			-- MemRead(4) MemWrite(3) MemToReg(2) jump(1) MFPC(0)
		);
		
	u19 : Registers
	port map(
			clk => clk,
			rst => rst,			
			readReg1 => ReadReg1MUXOut,
			readReg2 => ReadReg2MUXOut,
			WriteReg => MemWbWriteRegOut,
			WriteData => MemWbResultOut,
			RegWrite => MemWbRegWriteOut,
			
			readData1 => RegReadData1Out,
			readData2 => RegReadData2Out
		);
		
	u20 : imme_unit
	port map(
			 Im_in => command10to0Out,
			 Im_select => controllerOut(12 downto 10),
			 
			 Im_out => Im_out
		);
	
	u21 : ALU
	port map(
			input1 => ALUSrcAOut,
			input2 => ALUSrcBOut,
			contro => IdExeALUOpOut,
			
			result  => ALUresultOut,
			branch => branchOut
	);
	
	u22 : ReadReg1MUX
	port map(
			ten_downto_eight => command10to8Out,
			seven_downto_five => command7to5Out,
			contro => controllerOut(17 downto 15),
			
			ReadReg1Out => ReadReg1MUXOut
	);
	
	u23 : ReadReg2MUX
	port map(
			ten_downto_eight => command10to8Out,
			seven_downto_five => command7to5Out,
			contro => controllerOut(14 downto 13),
			
			ReadReg2Out => ReadReg2MUXOut

	);


end Behavioral;

