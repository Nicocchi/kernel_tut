BIN_DIR := bin
BUILD_DIR := build
SRC_DIR := src

TARGET := stdlib

CC_NAME := i686-elf
TARGET_ASM := nasm
TARGET_CC := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-gcc
TARGET_LD := ../../toolchain/$(CC_NAME)/$(BIN_DIR)/$(CC_NAME)-ld
TARGET_CC_FLAGS := -g -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer \
				-finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib \
				-nostartfiles -nodefaultlibs -Wall -O0 -Iinc

FILES := $(BUILD_DIR)/start.o $(BUILD_DIR)/pandora.asm.o $(BUILD_DIR)/stdlib.o $(BUILD_DIR)/stdio.o $(BUILD_DIR)/pandora.o $(BUILD_DIR)/string.o $(BUILD_DIR)/memory.o
INCLUDES := -I./src

all: clean folders start
	@printf "\e[0;32m\033[1m\n Compiling STDLIB... \n\n\033[0m\e[0;37m"
	$(TARGET_LD) -m elf_i386 -relocatable $(FILES) -o $(BIN_DIR)/$(TARGET).elf


start:
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/start.asm -o $(BUILD_DIR)/start.o
	$(TARGET_ASM) -f elf -g $(SRC_DIR)/pandora.asm -o $(BUILD_DIR)/pandora.asm.o
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/pandora.c -o $(BUILD_DIR)/pandora.o
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/stdlib.c -o $(BUILD_DIR)/stdlib.o
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/stdio.c -o $(BUILD_DIR)/stdio.o
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/string.c -o $(BUILD_DIR)/string.o
	$(TARGET_CC) $(INCLUDES) $(TARGET_CC_FLAGS) -std=gnu99 -c $(SRC_DIR)/memory.c -o $(BUILD_DIR)/memory.o

clean:
	@printf "\e[0;32m\033[1m\n Clearing files before building... \n\n\033[0m\e[0;37m"
	@rm -rf ./build
	@rm -rf ./bin

folders:
	@printf "\e[0;32m\033[1m\n Making build folders... \n\n\033[0m\e[0;37m"
	@printf "\n"
	mkdir -p bin
	mkdir -p build