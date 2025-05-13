BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := src

TARGET := pandora

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := $(abspath toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc)
TARGET_LD := $(abspath toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld)

SRC_FILES = ./build/kernel.asm.o

all: clean bootloader kernel write
	
write:
	@printf "\e[0;32m\033[1m\n Writing to $(TARGET).bin... \n\n\033[0m\e[0;37m"
	dd if=$(BIN_DIR)/boot.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=$(BIN_DIR)/kernel.bin >> $(BIN_DIR)/$(TARGET).bin
	dd if=/dev/zero bs=512 count=100 >> $(BIN_DIR)/$(TARGET).bin

bootloader:
	@printf "\e[0;32m\033[1m\n Assembling bootloader... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f bin -g $(SRC_DIR)/boot/boot.asm -o $(BIN_DIR)/boot.bin

kernel: $(SRC_DIR)/kernel.asm
	@printf "\e[0;32m\033[1m\n Assembling kernel... \n\n\033[0m\e[0;37m"
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/kernel.asm -o $(BUILD_DIR)/kernel.asm.o
	
	@printf "\e[0;32m\033[1m\n Linking kernel assembly... \n\n\033[0m\e[0;37m"
	$(TARGET_LD) -g -relocatable $(SRC_FILES) -o $(BUILD_DIR)/kernelfull.o

	@printf "\e[0;32m\033[1m\n Compiling kernel... \n\n\033[0m\e[0;37m"
	$(TARGET_CC) -T $(SRC_DIR)/linker.ld -o $(BIN_DIR)/kernel.bin -ffreestanding -O0 -nostdlib $(BUILD_DIR)/kernelfull.o

run:
	@printf "\e[0;32m\033[1m\n Running ${TARGET}.bin... \n\n\033[0m\e[0;37m"
	qemu-system-x86_64 -hda $(BIN_DIR)/${TARGET}.bin

clean:
	@printf "\e[0;32m\033[1m\n Clearing files before building... \n\n\033[0m\e[0;37m"
	@rm -rf ./bin/*
	@rm -rf ./build/*