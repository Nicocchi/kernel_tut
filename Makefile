all:
	nasm -f bin ./boot.asm -o ./boot.bin
	dd if=./test.txt >> ./boot.bin
	# Writes one sector after message and pipe it into the binary
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

run:
	qemu-system-x86_64 -hda ./boot.bin