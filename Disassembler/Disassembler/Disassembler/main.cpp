#include <cstdio>
#include<iostream>
#include <fstream>
using namespace std;


const int asm_total=48;//总共的指令数


struct AsmID
{
	char *name;
	int id;
};
AsmID RegsList[] = {
	{"R0",0},
	{"R1",1},
	{"R2",2},
	{"R3",3},
	{"R4",4},
	{"R5",5},
	{"R6",6},
	{"R7",7}
};

struct TASM
{
	char* name;
	int code;
	int x,y,z;
};
const struct TASM const_asm[] = {
	{"ADDSP3",1793,63743,65280,65535},
	{"B",4096,63488,65535,65535},
	{"BEQZ",9984,63743,65280,65535},
	{"BNEZ",12032,63743,65280,65535},
	{"SLL",14308,63743,65311,65507},
	{"SRL",14310,63743,65311,65507},
	{"SRA",14311,63743,65311,65507},
	{"ADDIU3",18400,63743,65311,65520},
	{"ADDIU",20224,63743,65280,65535},
	{"SLTI",22272,63743,65280,65535},
	{"SLTUI",24321,63743,65280,65535},
	{"BTEQZ",24576,65280,65535,65535},
	{"BTNEZ",24832,65280,65535,65535},
	{"SW_RS",25089,65280,65535,65535},
	{"ADDSP",25344,65280,65535,65535},
	{"MTSP",25824,65311,65535,65535},
	{"MOVE",32736,63743,65311,65535},  //changed by chenyong
	{"LI",28417,63743,65280,65535},
	{"CMPI",30465,63743,65280,65535},
	{"LW_SP",38657,63743,65280,65535},
	{"LW",40929,63743,65311,65504},
	{"SW_SP",55041,63743,65280,65535},
	{"SW",57313,63743,65311,65504},
	{"ADDU",59389,63743,65311,65507},
	{"SUBU",59391,63743,65311,65507},
	{"JR",61184,63743,65535,65535},
	{"MFHI",61200,63743,65535,65535},
	{"MFLO",61202,63743,65535,65535},
	{"MFPC",61248,63743,65535,65535},
	{"SLT",61410,63743,65311,65535},
	{"SLTU",61411,63743,65311,65535},
	{"SLLV",61412,63743,65311,65535},
	{"SRLV",61414,63743,65311,65535},
	{"SRAV",61415,63743,65311,65535},
	{"CMP",61418,63743,65311,65535},
	{"NEG",61419,63743,65311,65535},
	{"AND",61420,63743,65311,65535},
	{"OR",61421,63743,65311,65535},
	{"XOR",61422,63743,65311,65535},
	{"NOT",61423,63743,65311,65535},
	{"MULT",61432,63743,65311,65535},
	{"MULTU",61433,63743,65311,65535},
	{"DIV",61434,63743,65311,65535},
	{"DIVU",61435,63743,65311,65535},
	{"NOP",2048,65535,65535,65535,},
	{"INT",63489,65520,65535,65535},
	{"MFIH",63232,63743,65535,65535},
	{"MTIH",63233,63743,65535,65535}
};
char* get_hex(unsigned short num)
{
	char hex[4];
	int i,j;
	for (i=0;i<4;i++)
	{
		j = ((num & 0xF000) >> 12);
		num = (num << 4);
		if (j < 10)
			hex[i]=(char)(j+48);
		else hex[i]=(char)(j+55);
	}
	return hex;//局部数组指针，木有意义，不过没有调用到这个奇怪的函数>_<

}



int  pc_decode(unsigned short code, FILE* fp)
{

	char* argv[64];
	const struct TASM *p = const_asm;
	int i;
	unsigned short j ,k;
	for (i=0;i<asm_total;i++)
	{
		j = ((*p).code & (*p).x & (*p).y & (*p).z); 
		k = (code & (*p).x & (*p).y & (*p).z);
		if (j == k)
			break;
		p ++;
	}
	fprintf(fp, "  <%04x>    ",code);
	
	if (i == asm_total)	{
		fprintf(fp, "--- UNKNOWN ---  ");		
		cout<<endl;
		return -1;
	}

	int argc=0;
	fprintf(fp, " %s",(*p).name);	
	//strcpy(argv[argc],(*p).name);
	//argc++;
	unsigned short regs[3];
	unsigned short num;
	num=0x0000;
	regs[0] = ~(*p).x;
	regs[1] = ~(*p).y;
	regs[2] = ~(*p).z;
	for (i=0;i<3;i++)
	{
		if (regs[i] != 0)
		{
			k = (regs[i] & (*p).code);
			num = (regs[i] & code);
			if (regs[i] == k)
			{
				while ((regs[i] & 1) == 0)
				{
					num = (num >> 1);
					regs[i] = (regs[i] >> 1);
				}
				fprintf(fp, " R%d",num);	
				//argv[argc][0]='R';
				//argv[argc][1]=num+'0';
				//argc++;
			}
			else if (k == 0)
			{
				while ((regs[i] & 1) == 0)
				{
					num = (num >> 1);
					regs[i] = (regs[i] >> 1);
				}
				j = ~regs[i];
				if ((num & (j >> 1)) != 0)
					num = (num | j);
				fprintf(fp, " %04x",num);
				//strcpy(argv[argc],get_hex(num));
				//argc++;
			}
			else
			{
				while ((regs[i] & 1) == 0)
				{
					num = (num >> 1);
					regs[i] = (regs[i] >> 1);
				}
				//printf(" %04x",num);
				if ((num & 0x0010) !=0 && ((*p).name == "LW" || (*p).name == "SW"))
					fprintf(fp, " %04x",num | 0xffE0);
				else
					fprintf(fp, " %04x",num);
				//strcpy(argv[argc],get_hex(num));
				//argc++;
			}
		}//end  if(reg[i]!=0)
	}//end for 
	fprintf(fp, "\r\n");
	return 0;
}


int main(void)
{
	ifstream fin("kernel.bin", ios::binary);
	FILE* output=fopen("codes.txt", "wt");
	unsigned char a,b;
	for (int i=0;i<=0x217;i++)
	{
		fin.read((char*)&a, 1);
		fin.read((char*)&b, 1);
		int result = (unsigned)b * 0x100 + (unsigned)a;
		//printf("%d,%d\n",unsigned(a),unsigned(b));
		fprintf(output, "%x\t",i);
		pc_decode(result,output);
	}
	fclose(output);
	return(0);
}