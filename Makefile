BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := src

TARGET := pandora

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc
TARGET_LD := toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld
TARGET_CC_FLAGS := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer \
				-finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

BUILD_FILES := $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/idt/idt.asm.o $(BUILD_DIR)/idt/idt.o $(BUILD_DIR)/memory/memory.o \
			$(BUILD_DIR)/io/io.asm.o $(BUILD_DIR)/memory/heap/heap.o $(BUILD_DIR)/memory/heap/kheap.o $(BUILD_DIR)/memory/paging/paging.asm.o \
			$(BUILD_DIR)/memory/paging/paging.o $(BUILD_DIR)/disk/disk.o $(BUILD_DIR)/string/string.o $(BUILD_DIR)/fs/pparser.o $(BUILD_DIR)/disk/streamer.o \
			$(BUILD_DIR)/fs/fat/fat16.o $(BUILD_DIR)/fs/file.o
INCLUDES := -I./$(SRC_DIR) -I./$(SRC_DIR)/disk -I./$(SRC_DIR)/fs -I./$(SRC_DIR)/fs/fat -I./$(SRC_DIR)/idt -I./$(SRC_DIR)/memory -I./$(SRC_DIR)/io -I./$(SRC_DIR)/memory/heap -I./$(SRC_DIR)/string

all: clean folders bootloader kernel write
	
write:
	@printf "\e[0;32m\033[1m\n Writing to $(TARGET).bin... \n\n\033[0m\e[0;37m"
	dd if=$(BIN_DIR)/boot.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=$(BIN_DIR)/kernel.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=/dev/zero bs=1048576 count=16 >> $(BIN_DIR)/$(TARGET).bin
	sudo mount -t vfat $(BIN_DIR)/$(TARGET).bin /mnt/d
	# Copy a file over
	sudo cp ./nico.txt /mnt/d
	sudo umount /mnt/d

bootloader:
	@printf "\e[0;32m\033[1m\n Assembling bootloader... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f bin -g $(SRC_DIR)/boot/boot.asm -o $(BIN_DIR)/boot.bin

kernel:
	@printf "\e[0;32m\033[1m\n Assembling kernel... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/kernel.asm -o $(BUILD_DIR)/kernel.asm.o
	@printf "\n"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o
	@printf "\e[0;32m\033[1m\n idt... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/idt/idt.asm -o $(BUILD_DIR)/idt/idt.asm.o
	@printf "\n"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/idt/idt.c -o $(BUILD_DIR)/idt/idt.o
	@printf "\e[0;32m\033[1m\n memory... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/memory/memory.c -o $(BUILD_DIR)/memory/memory.o
	
	@printf "\e[0;32m\033[1m\n io... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/io/io.asm -o $(BUILD_DIR)/io/io.asm.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Heap... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/memory/heap/heap.c -o $(BUILD_DIR)/memory/heap/heap.o
	@printf "\n"
	
	@printf "\e[0;32m\033[1m\n KHeap... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/memory/heap/kheap.c -o $(BUILD_DIR)/memory/heap/kheap.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Paging... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/memory/paging/paging.c -o $(BUILD_DIR)/memory/paging/paging.o
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/memory/paging/paging.asm -o $(BUILD_DIR)/memory/paging/paging.asm.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Disk... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/disk/disk.c -o $(BUILD_DIR)/disk/disk.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n String... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/string/string.c -o $(BUILD_DIR)/string/string.o
	@printf "\n"
	
	@printf "\e[0;32m\033[1m\n FAT16... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/fs/fat/fat16.c -o $(BUILD_DIR)/fs/fat/fat16.o
	@printf "\n"
	
	@printf "\e[0;32m\033[1m\n File... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/fs/file.c -o $(BUILD_DIR)/fs/file.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Path Parser... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/fs/pparser.c -o $(BUILD_DIR)/fs/pparser.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Disk Streamer... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/disk/streamer.c -o $(BUILD_DIR)/disk/streamer.o
	@printf "\n"

	@printf "\e[0;32m\033[1m\n Linking kernel assembly... \n\n\033[0m\e[0;37m"
	$(TARGET_LD) -g -relocatable $(BUILD_FILES) -o $(BUILD_DIR)/kernelfull.o

	@printf "\e[0;32m\033[1m\n Compiling kernel... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(TARGET_CC_FLAGS) -T $(SRC_DIR)/linker.ld -o $(BIN_DIR)/kernel.bin -ffreestanding -O0 -nostdlib $(BUILD_DIR)/kernelfull.o

folders:
	@printf "\e[0;32m\033[1m\n Making build folders... \n\n\033[0m\e[0;37m"
	@printf "\n"
	mkdir -p bin
	mkdir -p build
	mkdir -p build/disk
	mkdir -p build/fs
	mkdir -p build/fs/fat
	mkdir -p build/idt
	mkdir -p build/memory
	mkdir -p build/memory/heap
	mkdir -p build/memory/paging
	mkdir -p build/string
	mkdir -p build/io

run:
	@printf "\e[0;32m\033[1m\n Running ${TARGET}.bin... \n\n\033[0m\e[0;37m"
	qemu-system-x86_64 -hda $(BIN_DIR)/${TARGET}.bin

clean:
	@printf "\e[0;32m\033[1m\n Clearing files before building... \n\n\033[0m\e[0;37m"
	@rm -rf ./bin
	@rm -rf ./build
