#include <stdio.h>

int main () {
	int i=0;
	char* pcVideoMemory = (char*)0xB8000;

	while (1) {
		pcVideoMemory[i]=0; // text part
		pcVideoMemory[i+1]=0x0A; // attr part

		i+=2; // 1 character == 2byte (1 text, 1 attr)

		if (i>=80*25*2) break;
	}
}
