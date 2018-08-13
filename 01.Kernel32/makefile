all: Kernel32.bin 

Kernel32.bin: Source/EntryPoint.s
	nasm -o Kernel32.bin $<
# $< macro: First file on dependency list

clean:
	rm -f Kernel32.bin

