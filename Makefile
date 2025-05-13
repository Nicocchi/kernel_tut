BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := src

TARGET := pandora

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc
TARGET_LD := toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld
TARGET_CC_FLAGS := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

BUILD_FILES := $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/idt/idt.asm.o $(BUILD_DIR)/idt/idt.o $(BUILD_DIR)/memory/memory.o
INCLUDES := -I./$(SRC_DIR) -I./$(SRC_DIR)/idt -I./$(SRC_DIR)/memory

all: clean folders bootloader kernel write
	
write:
	@printf "\e[0;32m\033[1m\n Writing to $(TARGET).bin... \n\n\033[0m\e[0;37m"
	dd if=$(BIN_DIR)/boot.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=$(BIN_DIR)/kernel.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=/dev/zero bs=512 count=100 >> $(BIN_DIR)/$(TARGET).bin

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
	
	@printf "\e[0;32m\033[1m\n Linking kernel assembly... \n\n\033[0m\e[0;37m"
	$(TARGET_LD) -g -relocatable $(BUILD_FILES) -o $(BUILD_DIR)/kernelfull.o

	@printf "\e[0;32m\033[1m\n Compiling kernel... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) $(TARGET_CC_FLAGS) -T $(SRC_DIR)/linker.ld -o $(BIN_DIR)/kernel.bin -ffreestanding -O0 -nostdlib $(BUILD_DIR)/kernelfull.o

folders:
	mkdir -p bin
	mkdir -p build
	mkdir -p build/idt
	mkdir -p build/memory

run:
	@printf "\e[0;32m\033[1m\n Running ${TARGET}.bin... \n\n\033[0m\e[0;37m"
	qemu-system-x86_64 -hda $(BIN_DIR)/${TARGET}.bin

clean:
	@printf "\e[0;32m\033[1m\n Clearing files before building... \n\n\033[0m\e[0;37m"
	@rm -rf ./bin
	@rm -rf ./build