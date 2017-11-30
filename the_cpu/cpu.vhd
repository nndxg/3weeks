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
			clk_hand : in std_logic; --ʱ��Դ  Ĭ��Ϊ50M  ����ͨ���޸İ󶨹ܽ����ı�
			clk_50 : in std_logic;
			opt : in std_logic;	--ѡ������ʱ�ӣ�Ϊ�ֶ�����50M��
			
			
			--����
			dataReady : in std_logic;   
			tbre : in std_logic;
			tsre : in std_logic;
			rdn : inout std_logic;
			wrn : inout std_logic;
			
			--RAM1  �������
			ram1En : out std_logic;
			ram1We : out std_logic;
			ram1Oe : out std_logic;
			ram1Data : inout std_logic_vector(15 downto 0);
			ram1Addr : out std_logic_vector(17 downto 0);
			
			--RAM2 ��ų����ָ��
			ram2En : out std_logic;
			ram2We : out std_logic;
			ram2Oe : out std_logic;
			ram2Data : inout std_logic_vector(15 downto 0);
			ram2Addr : out std_logic_vector(17 downto 0);
			
			--debug  digit1��digit2��ʾPCֵ��led��ʾ��ǰָ��ı���
			digit1 : out std_logic_vector(6 downto 0);	--7λ�����1
			digit2 : out std_logic_vector(6 downto 0);	--7λ�����2
			led : out std_logic_vector(15 downto 0);
			
			hs,vs : out std_logic;
			redOut, greenOut, blueOut : out std_logic_vector(2 downto 0)
	);
end cpu;

architecture Behavioral of cpu is
	component Memory_unit
	port(
		--ʱ��
		clk : in std_logic;
		rst : in std_logic;
		
		--RAM1�����ڣ�
		data_ready : in std_logic;		--����׼���źţ�='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data��
		tbre : in std_logic;				--�������ݱ�־
		tsre : in std_logic;				--���ݷ�����ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;				--д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����RAM1data���ã�����Ϊ'1'д����
		rdn : out std_logic;				--�����ڣ���ʼ��Ϊ'1'����RAM1data��Ϊ"ZZ..Z"��
												--��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������RAM1data�ϣ�
		
		--RAM2��IM+DM��
		MemRead : in std_logic;							--���ƶ�DM���źţ�='1'������Ҫ��
		MemWrite : in std_logic;						--����дDM���źţ�='1'������Ҫд
		
		dataIn : in std_logic_vector(15 downto 0);		--д�ڴ�ʱ��Ҫд��DM��IM������
		
		ramAddr : in std_logic_vector(15 downto 0);		--��DM/дDM/дIMʱ����ַ����
		PCOut : in std_logic_vector(15 downto 0);		--��IMʱ����ַ����
		PCMuxOut : in std_logic_vector(15 downto 0);	
		PCKeep : in std_logic;
		
		dataOut : out std_logic_vector(15 downto 0);	--��DMʱ��������������/�����Ĵ���״̬
		insOut : out std_logic_vector(15 downto 0);		--��IMʱ��������ָ��
		
		ram1_addr : out std_logic_vector(17 downto 0); 	--RAM1��ַ����
		ram2_addr : out std_logic_vector(17 downto 0); 	--RAM2��ַ����
		ram1_data : inout std_logic_vector(15 downto 0);--RAM1��������
		ram2_data : inout std_logic_vector(15 downto 0);--RAM2��������
		
		ram2AddrOutput : out std_logic_vector(17 downto 0);
		
		ram1_en : out std_logic;		--RAM1ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_oe : out std_logic;		--RAM1��ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_we : out std_logic;		--RAM1дʹ�ܣ�='1'��ֹ����Զ����'1'
		
		ram2_en : out std_logic;		--RAM2ʹ�ܣ�='1'��ֹ����Զ����'0'
		ram2_oe : out std_logic;		--RAM2��ʹ�ܣ�='1'��ֹ
		ram2_we : out std_logic		--RAM2дʹ�ܣ�='1'��ֹ		
		
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
			seven_downto_five : in std_logic_vector(2 downto 0);			--R0~R7�е�һ��
			
			contro : in std_logic_vector(2 downto 0);		--���ܿ�����Controller���ɵĿ����ź�
			
			ReadReg1Out : out std_logic_vector(3 downto 0)  --"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
		);
	end component;
	
	component ReadReg2MUX
		port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			
			contro : in std_logic_vector(1 downto 0);
			
			ReadReg2Out : out std_logic_vector(3 downto 0)  --"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
		);
	end component;
	
	component ReadDstMUX
		port(
			ten_downto_eight : in std_logic_vector(2 downto 0);
			seven_downto_five : in std_logic_vector(2 downto 0);
			four_downto_two : in std_logic_vector(2 downto 0);
			contro : in std_logic_vector(2 downto 0);
			
			ReadDstOut : out std_logic_vector(3 downto 0)  --"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1110"=û��
		);
	end component;
	
	component Registers
		Port(
			clk:in std_logic;
			rst:in std_logic;
			RegWrite:in std_logic;
			readReg1:in std_logic_vector(3 downto 0);--"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T
			readReg2:in std_logic_vector(3 downto 0);--"0XXX"����R0~R7
			WriteReg:in std_logic_vector(3 downto 0);--"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T
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
			ALUresult:out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
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
	
	component ALUMuxA
	port(
		--�����ź�
		ForwardA : in std_logic_vector(1 downto 0);
		--��ѡ������
		readData1 : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- ����ָ���ALU������ϸ�˵��MFPCMux�Ľ����
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- ������ָ����������NOP����д�صļĴ���ֵ(WriteData)
		--ѡ�������
		ALUSrcA : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--ѡ������ALU�ĵڶ���������
	component ALUMuxB
	port(
		--�����ź�
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrcB  : in std_logic;
		--��ѡ������
		readData2 : in std_logic_vector(15 downto 0);
		imme 	    : in std_logic_vector(15 downto 0);
		ExeMemALUResult : in std_logic_vector(15 downto 0);	-- ����ָ���ALU������ϸ�˵��MFPCMux�Ľ����
		MemWbWriteData : in std_logic_vector(15 downto 0);	   -- ������ָ����������NOP����д�صļĴ���ֵ(WriteData)
		--ѡ�������
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
	--��MFPCָ���PC+1��ALUResult��ѡ��һ����Ϊ"������ALUResult" ???
	port(
		PCAddOne  : in std_logic_vector(15 downto 0);	
		RawALUResult : in std_logic_vector(15 downto 0); -- ALU������
		isMFPC		 : in std_logic;		-- isMFPC = '1' ��ʾ��ǰָ����MFPC��ѡ��PC+1��ֵ
		
		RealALUResult : out std_logic_vector(15 downto 0)
	);
	end component;
	
	component ExMemRegisters
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
		ExeMemWriteReg : in std_logic_vector(3 downto 0);   -- ����ָ��д�صļĴ��� 
		MemWbWriteReg : in std_logic_vector(3 downto 0);    -- ������ָ��д�صļĴ��� 
		
		IdExeMemWrite : in std_logic;
		
		IdExeReadReg1 : in std_logic_vector(3 downto 0);  -- ����ָ���Դ�Ĵ���1
		IdExeReadReg2 : in std_logic_vector(3 downto 0);  -- ����ָ���Դ�Ĵ���2
		
		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0)	     -- ѡ��SW/SW_SP��WriteData
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
		IdExeFlush_LW : in std_logic;		            --LW���ݳ�ͻ��
		IdExeFlush_StructConflict : in std_logic;		--SW�ṹ��ͻ��
		
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
		ExeMemWriteReg: in std_logic_vector(15 downto 0);
		
		MemWbRegWrite: out std_logic;
		MemWbWriteReg: out std_logic_vector(15 downto 0);
		WriteData: out std_logic_vector(15 downto 0)
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
	
	
	--Memory_unit ����һ�󲿷ֶ�����cpu��port�����֣�
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
	signal ALUresult : std_logic_vector(15 downto 0);
	signal branch : std_logic;
	
	--ReadReg1MUX
	signal ReadReg1MUXOut : std_logic_vector(3 downto 0);
	
	--ReadReg2MUX
	signal ReadReg2MUXOut : std_logic_vector(3 downto 0);
	
	--ALUMuxA
	signal ALUSrcA : std_logic_vector(15 downto 0);
	
	--ALUMuxB
	signal ALUSrcB : std_logic_vector(15 downto 0);
	
	--ExeMemRegisters
	signal ExeMemRegWrite : std_logic;
	signal ExeMemWBSrc: std_logic;
	signal ExeMemMemRead: std_logic;
	signal ExeMemMemWrite: std_logic;
	signal ExeMemALUResultOut: std_logic_vector(15 downto 0);
	signal MemWriteDataOut: std_logic_vector(15 downto 0);
	signal ExeMemWriteReg: std_logic_vector(3 downto 0);
	
	--Forwarding_unit
	signal ForwardA : std_logic_vector(1 downto 0);
	signal ForwardB : std_logic_vector(1 downto 0);
	signal ForwardSW : std_logic_vector(1 downto 0);
	
	--HazardDetectionUnit
	signal IdExeFlush_LW: std_logic;
	signal PCKeep: std_logic;
	signal IfIdKeep_LW: std_logic;
	
	--IdExeRegisters
	signal RegWriteOut : std_logic;
	signal WBSrcOut : std_logic;
	signal MemWriteOut : std_logic;
	signal MemReadOut : std_logic;
	signal isMFPCOut : std_logic;
	signal isJumpOut : std_logic;
	signal ALUOpOut : std_logic_vector(3 downto 0);
	signal ALUSrcBOut : std_logic;
		
	signal PCPlusOneOut : std_logic_vector(15 downto 0);
	signal ReadReg1Out : std_logic_vector(3 downto 0);		
	signal ReadReg2Out : std_logic_vector(3 downto 0);
	signal ReadData1Out : std_logic_vector(15 downto 0);	
	signal ReadData2Out : std_logic_vector(15 downto 0);			
	signal IdExeImme : std_logic_vector(15 downto 0);	
	signal WriteRegOut : std_logic_vector(3 downto 0);
	
	--IfIdRegisters
	signal PCPlusOneOut: std_logic_vector(15 downto 0);
	signal CommandOut: std_logic_vector(15 downto 0);
	signal command10to8: std_logic_vector(2 downto 0);
	signal command7to5: std_logic_vector(2 downto 0);
	signal command4to2: std_logic_vector(2 downto 0);
	signal command10to0: std_logic_vector(10 downto 0);
	
	--MFPCMux
	signal RealALUResult : std_logic_vector(15 downto 0);
	
	--MemWbRegisters
	signal MemWbRegWrite: std_logic;
	signal MemWbWriteReg: std_logic_vector(15 downto 0);
	signal MemWbResult: std_logic_vector(15 downto 0);
	
	--MemWriteDataMux
	signal WriteData : std_logic_vector(15 downto 0);
	
	--PCBrancherAdder
	signal PCAfterBranch: std_logic_vector(15 downto 0);
	
	--PCIncrementer
	signal PCPlusOne: std_logic_vector(15 downto 0);
	
	--PCMux
	signal selectedPC: std_logic_vector(15 downto 0);
	
	--PCRegister
	signal nextPC: std_logic_vector(15 downto 0);
	
	--StructConflictUnit
	signal IfIdFlush_StructConflict: std_logic;
	signal IdExeFlush_StructConflict: std_logic;
	signal PCRollBack: std_logic;
	
begin
	u1 : ALUMuxA
	port map(
			ForwardA => ForwardA,
			readData1 => ReadData1Out,
			ExeMemALUResult => ExeMemALUResultOut,
			MemWbWriteData => MemWbResult,

			ALUSrcA => ALUSrcA
		);
		
	u2 : ALUMuxB
	port map(
			ForwardB => ForwardB,
			readData2 => ReadData2Out,
			ExeMemALUResult => ExeMemALUResultOut,
			MemWbWriteData => MemWbResult,

			ALUSrcB => ALUSrcB
		);
	
	u3 : ExeMemRegisters
	port map(
			rst => rst,
			clk => clk,
			IdExeRegWrite => RegWriteOut,
			IdExeWBSrc => WBSrcOut,
			IdExeMemRead => MemReadOut,
			IdExeMemWrite => MemWriteOut,
			RealALUResultIn => RealALUResult,
			MemWriteDataIn => WriteData,
			IdExeWriteReg => WriteRegOut,

			ExeMemRegWrite => ExeMemRegWrite,
			ExeMemWBSrc => ExeMemWBSrc,
			ExeMemMemRead => ExeMemMemRead,
			ExeMemMemWrite => ExeMemMemWrite,
			ALUResultOut => ExeMemALUResultOut,
			MemWriteDataOut => MemWriteDataOut,
			ExeMemWriteReg => ExeMemWriteReg
		);
		
	u4 : Forwarding_unit
	port map(
			ExeMemWriteReg => ExeMemWriteReg,
			MemWbWriteReg => MemWbWriteReg,
			IdExeMemWrite => MemWriteOut,
			IdExeReadReg1 => ReadReg1Out,
			IdExeReadReg2 => ReadReg1Out,

			ForwardA => ForwardA,
			ForwardB => ForwardB,
			ForwardSW => ForwardSW
		);
		
	u5 : HazardDetectionUnit
	port map(
			IdExeMemRead => MemReadOut,
			IdExeWriteReg => WriteRegOut,
			readReg1 => ReadReg1MUXOut,
			readReg2 => ReadReg2MUXOut,

			IdExeFlush_LW => IdExeFlush_LW,
			PCKeep => PCKeep,
			IfIdKeep_LW => IfIdKeep_LW
		);
		
	u6 : IdExeRegisters
	port map(
			rst => rst,
			clk => clk,
			IdExeFlush_LW => IdExeFlush_LW,
			IdExeFlush_StructConflict => IdExeFlush_StructConflict,
			RegWriteIn => rst,
			WBSrcIn => clk,
			MemWriteIn => rst,
			MemReadIn => clk,
			isMFPCIn => rst,
			isJumpIn => clk,
			ALUOpIn => rst,
			ALUSrcBIn => clk,
			PCPlusOneIn => clk,
			ReadReg1In => clk,
			ReadReg2In => clk,
			ReadData1In => clk,
			ReadData2In => clk,
			ImmeIn => clk,
			WriteRegIn => clk,

			RegWriteOut => RegWriteOut,
			WBSrcOut => WBSrcOut,
			MemWriteOut => MemWriteOut,
			MemReadOut => MemReadOut,
			isMFPCOut => isMFPCOut,
			isJumpOut => isJumpOut,
			ALUOpOut => ALUOpOut,
			ALUSrcBOut => ALUSrcBOut,
			PCPlusOneOut => PCPlusOneOut,
			ReadReg1Out => ReadReg1Out,
			ReadReg2Out => ReadReg2Out,
			ReadData1Out => ReadData1Out,
			ReadData2Out => ReadData2Out,
			ImmeOut => IdExeImme,
			WriteRegOut => WriteRegOut
		);
	
	u7 : IfIdRegisters
	port map(
			rst => rst,
			clk => clk,
			isJump => isJumpOut,
			willBranch => branch,
			IfIdFlush_StructConflict => IfIdFlush_StructConflict,
			IfIdKeep_LW => IfIdKeep_LW,
			PCPlusOneIn => PCPlusOne,
			CommandIn => InsOut,

			PCPlusOneOut => PCPlusOneOut,
			CommandOut => CommandOut,
			command10to8 => command10to8,
			command7to5 => command7to5,
			command4to2 => command4to2,
			command10to0 => command10to0
		);
	
	u8 : MFPCMux
	port map(
			PCAddOne => PCPlusOneOut,
			RawALUResult => ALUresult,
			isMFPC => isMFPCOut,

			RealALUResult => RealALUResult
		);
	
	u9 : MemWbRegisters
	port map(
			rst => rst,
			clk => clk,
			ExeMemRegWrite => ExeMemRegWrite,
			ExeMemWBSrc => ExeMemWBSrc,
			ExeMemWriteReg => ExeMemWriteReg,
			MemReadData => DataOut,
			ALUResult => RealALUResult,

			MemWbRegWrite => MemWbRegWrite,
			MemWbWriteReg => MemWbWriteReg,
			WriteData => MemWbResult
		);
		
	u10 : MemWriteDataMux
	port map(
			ForwardSW => ForwardSW,
			ExeMemALUResult => ExeMemALUResultOut,
			readData2 => readData2,
			MemWbResult => MemWbResult,

			WriteData => WriteData
		);
		
	u11 : PCBrancherAdder
	port map(
			PCPlusOne => PCPlusOne,
			IdExeImme => IdExeImme,

			PCAfterBranch => PCAfterBranch
		);
		
	u12 : PCIncrementer
	port map(
			
			PCin => nextPC,

			PCPlusOne => PCPlusOne
		);
		
	u13 : PCMux
	port map(
			
			PCPlusOne => PCPlusOne,
			ALUResult => ALUresult,
			PCAfterBranch => PCAfterBranch,
			isJump => isJumpOut,
			willBranch => branch,
			PCRollBack => PCRollBack,

			selectedPC => selectedPC
		);
		
	u14 : PCRegister
	port map(
			
			clk => clk,
			rst => rst,
			PCKeep => PCKeep,
			selectedPC => selectedPC,

			nextPC => nextPC
		);
	
	u15 : StructConflictUnit
	port map(
			
			IdExeMemWrite => IdExeMemWrite,
			ALUResult => ALUresult,

			IfIdFlush_StructConflict => IfIdFlush_StructConflict,
			IdExeFlush_StructConflict => IdExeFlush_StructConflict,
			PCRollBack => PCRollBack
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

	u17 : ReadDstMUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			four_downto_two => four_downto_two,
			
			contro => controller(20 downto 18),
			ReadDstOut => ReadDstOut
		);
		
	u18 : Controller
	port map(	
			command => IfIdCommand,
			rst => rst,
			controller => controller
			-- RegWrite(21) RegDst(20-18) ReadReg1(17-15) ReadReg2(14-13) 
			-- immeSelect(12-10) ALUSrcB(9) ALUOp(8-5) 
			-- MemRead(4) MemWrite(3) MemToReg(2) jump(1) MFPC(0)
		);
		
	u19 : Registers
	port map(
			clk => clk,
			rst => rst,
			
			readReg1 => ReadReg1Out,
			readReg2 => ReadReg2Out,
			
			--����������MEM/WB�μĴ�������Ϊ������д�ضΣ�
			WriteReg => rdToWB,
			WriteData => dataToWB,
			contro => MemWbRegWrite,
			
			readData1 => readData1,
			readData2 => readData2
		);
		
	u20 : imme_unit
	port map(
			 Im_in => imme_10_0,
			 Im_select => controller(12 downto 10),
			 
			 Im_out => extendedImme
		);
	
	u21 : ALU
	port map(
			input1      	=> AMuxOut,
			input2        => BMuxOut,
			contro		  	=> IdExALUOP,
			
			result  	=> ALUresult,
			branch => branch
	);
	
	u22 : ReadReg1MUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			contro => controller(17 downto 15),
			
			ReadReg1Out => ReadReg1MUXOut
	);
	
	u23 : ReadReg2MUX
	port map(
			ten_downto_eight => ten_downto_eight,
			seven_downto_five => seven_downto_five,
			contro => controller(14 downto 13),
			
			ReadReg2Out => ReadReg2MUXOut

	);


end Behavioral;

