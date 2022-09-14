#include <cstdint>
#include <iostream>
#include <fstream>
using namespace std;


//opcodes
/*
0000011
LB, LH, LW, LBU, LHU

0100011
SB, SH, SW

1100111
JALR

1101111
JAL

0110011
SLL SRL SRA

0010011
SLLI SRLI SRAI

0110011
ADD SUB LUI

0010011
ADDI

0010111
AUIPC

0010011
XORI ORI ANDI

0110011
XOR OR AND

0110011
SLT SLTU

0010011
SLTI SLTIU

1100011
BEQ BNE BLT BGE BLTU BGEU
*/

//3 bit func3
//7 bit opcode
//1 bit bit30
//5 bit shamt_i

// 5 bit:
// rd, rs1, rs2

//32 bits:
//imm_b
//imm_j
//imm_i
//imm_u
//int address = 0;

uint32_t* inst;
int index = 0;


void ADDI(int rd, int rs, int imm) {
	//?????????????????000?????0010011
	inst[index++] = (0x13) | (rd << 7) | (0 << 12) | (rs << 15) | (imm << 20);
}

void ADD(int rd, int rs1, int rs2) {
	//0000000??????????000?????0110011
	inst[index++] = (0x33) | (rd << 7) | (0 << 12) | (rs1 << 15) | (rs2 << 20) | (0x0 << 25);
}

void SUB(int rd, int rs1, int rs2) {
	//0100000??????????000?????0110011
	inst[index++] = (0x33) | (rd << 7) | (0 << 12) | (rs1 << 15) | (rs2 << 20) | (0x20 << 25);
}

void XOR(int rd, int rs1, int rs2) {
	//0000000??????????100?????0110011
	inst[index++] = (0x33) | (rd << 7) | (0x100 << 12) | (rs1 << 15) | (rs2 << 20) | (0x0 << 25);
}

void AND(int rd, int rs1, int rs2) {
	//0000000??????????111?????0110011
	inst[index++] = (0x33) | (rd << 7) | (0x111 << 12) | (rs1 << 15) | (rs2 << 20) | (0x0 << 25);
}

void OR(int rd, int rs1, int rs2) {
	//0000000??????????110?????0110011
	inst[index++] = (0x33) | (rd << 7) | (0x110 << 12) | (rs1 << 15) | (rs2 << 20) | (0x0 << 25);
}

void JAL() {

}

void JALR() {

}

void program();

int main() {


	inst = new uint32_t[32];

	for (int i = 0; i < 32; i++) {
		inst[i] = 0;
	}

	program();
	
	char* data = new char[128];
	void* temp = inst;
	data = (char*)temp;

	ofstream myfile;
	myfile.open("data.txt");
	
	//myfile << "0x1f";
	//

	myfile << std::hex;

	for (int i = 0; i < 32; i++) {
		myfile << (int)inst[i] << "\n";

	}

	myfile.close();
	return 0;
}

void program() {


	ADDI(1, 1, 15);
	ADDI(1, 1, 3);
	ADDI(1, 2, 2);
	ADDI(1, 2, 5);
	//ADD(3, 1, 2);
	//SUB(4, 1, 2);


}