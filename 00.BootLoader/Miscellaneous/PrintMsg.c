#include <stdio.h>

int main () {
	int i, j=0;
	char* pcVideoMemory = (char*)0xB800;
	char* pcMessage = "MINT64 OS Boot Loader Start!!";
	char cTemp;

	while (1) {
		cTemp = pcMessage[i];
		if (cTemp==0) break;
		pcVideoMemory[j]=cTemp;
		i+=1;
		j+=2;
	}
}
