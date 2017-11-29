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
			
			--����������MEM/WB�μĴ�������Ϊ������д�ضΣ�
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

