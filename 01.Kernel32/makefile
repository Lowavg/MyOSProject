<<<<<<< HEAD
all: Kernel32.bin 

Kernel32.bin: Source/EntryPoint.s
	nasm -o Kernel32.bin $<
# $< macro: First file on dependency list

clean:
	rm -f Kernel32.bin
=======
all: VirtualOS.bin

VirtualOS.bin: VirtualOS.asm
	nasm -o VirtualOS.bin VirtualOS.asm

clean:
	rm -f VirtualOS.bin
>>>>>>> 8b6709a2592a4c4243214c50badcca2858a6e5ae
