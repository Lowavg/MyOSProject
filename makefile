all: BootLoader Kernel32 Disk.img

BootLoader:
	@echo Build BootLoader
	make -C 00.BootLoader
	@echo Build Complete

Kernel32:
	@echo Build 32bit Kernel
	make -C 01.Kernel32
	@echo Build Complete

<<<<<<< HEAD
Disk.img: 00.BootLoader/BootLoader.bin 01.Kernel32/Kernel32.bin
	@echo Build Disk Image
	cat $^>Disk.img 
	@echo All Build Complete
# $^ macro: Every files on dependency list

=======
Disk.img:
	@echo Build Disk Image
	cat 00.BootLoader/BootLoader.bin 01.Kernel32/VirtualOS.bin > Disk.img
	@echo All Build Complete
>>>>>>> 8b6709a2592a4c4243214c50badcca2858a6e5ae

clean:
	make -C 00.BootLoader clean
	make -C 01.Kernel32 clean
	rm -f Disk.img
