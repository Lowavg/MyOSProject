all: BootLoader Kernel32 Disk.img

BootLoader:
	@echo Build BootLoader
	make -C 00.BootLoader
	@echo Build Complete

Kernel32:
	@echo Build 32bit Kernel
	make -C 01.Kernel32
	@echo Build Complete

Disk.img:
	@echo Build Disk Image
	cat 00.BootLoader/BootLoader.bin 01.Kernel32/VirtualOS.bin > Disk.img
	@echo All Build Complete

clean:
	make -C 00.BootLoader clean
	make -C 01.Kernel32 clean
	rm -f Disk.img
