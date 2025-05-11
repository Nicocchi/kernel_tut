# pandora

### Dependencies
* [NASM](https://github.com/netwide-assembler/nasm)
* [QEMU](https://github.com/qemu/qemu) Debugging the system

### Build

#### Bootloader
```nasm -f bin ./boot.asm -o ./boot.bin```

### Run
qemu-system-x86_64 -hda ./boot.bin