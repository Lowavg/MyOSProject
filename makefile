all: BootLoader Disk.img

BootLoader:
	@echo Build BootLoader
	make -C 00.BootLoader
	@echo Build Complete

Disk.img:
	@echo Build Disk Image
	cp 00.BootLoader/BootLoader.bin Disk.img
	@echo All Build Complete

clean:
	make -C 00.BootLoader clean
	rm -f Disk.img
