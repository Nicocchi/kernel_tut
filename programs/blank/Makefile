BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := src

TARGET := blank

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc
TARGET_LD := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld
TARGET_CC_FLAGS := -ffreestanding -O0 -nostdlib -fpic -g

all: clean folders blank

blank:
	@printf "\e[0;32m\033[1m\n Compiling Blank program... \n\n\033[0m\e[0;37m"
	cd ../../
	$(TARGET_ASM) -f elf ./$(TARGET).asm -o ./$(BUILD_DIR)/$(TARGET).o
	$(TARGET_CC) -g -T ./linker.ld -o ./$(BIN_DIR)/$(TARGET).bin $(TARGET_CC_FLAGS) ./$(BUILD_DIR)/$(TARGET).o
	@printf "\n"

clean:
	@printf "\e[0;32m\033[1m\n Clearing files before building... \n\n\033[0m\e[0;37m"
	@rm -rf ./build
	@rm -rf ./bin

folders:
	@printf "\e[0;32m\033[1m\n Making build folders... \n\n\033[0m\e[0;37m"
	@printf "\n"
	mkdir -p bin
	mkdir -p build