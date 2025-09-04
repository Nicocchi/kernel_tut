BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := ./

TARGET := blank

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc
TARGET_LD := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld
TARGET_CC_FLAGS := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer \
				-finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib \
				-nostartfiles -nodefaultlibs -Wall -O0 -Iinc

FILES := $(BUILD_DIR)/$(TARGET).o
INCLUDES := -I./ -I../stdlib/src/

all: clean folders blank
	@printf "\e[0;32m\033[1m\n Compiling Blank program... \n\n\033[0m\e[0;37m"
	$(TARGET_LD) -g -T ./linker.ld -o ./$(BIN_DIR)/$(TARGET).elf $(FILES) ../stdlib/bin/stdlib.elf

blank:
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/$(TARGET).c -o $(BUILD_DIR)/$(TARGET).o
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