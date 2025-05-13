# pandora




## Compiling

### Preparing to build the cross-compiler

You will need to following to build gcc:
* Bison
* Flex
* GMP
* MPC
* MPFR
* Texinfo

You can find more information on cross-compiling gcc, including links and package names for each of the dependencies, for Linux distros on the [osdev wiki page](https://wiki.osdev.org/GCC_Cross-Compiler#Preparing_for_the_build).

### Building
To setup the cross-compiler, run the `toolchain.sh` script from the main directory. This will download **binutils** and **gcc**, configure them, and compile them into the `toolchain` directory and then test to see if **gcc** is properly installed.

*Note: You can change the version for binutils and gcc in the script if needed.*

### Perparing to build the kernel & bootloader
* [NASM](https://github.com/netwide-assembler/nasm)
* [QEMU](https://github.com/qemu/qemu) Debugging and running the kernel

Entering `make` in the terminal will start the building process for **both the bootloader and kernel** and output it to the final binary **pandora.bin**. If you want to build each separately, use the commands below in the following order:

#### Bootloader
`make bootloader`

#### Kernel
`make kernel`

#### Disk
`make write`

*Note: The bootloader must be built first before the kernel and the disk must be done last.*

## Running the kernel
The kernel will be outputted into **pandora.bin**. You can either use the make command `make run` to start **qemu** with the binary file or manually run **qemu** with `qemu-system-x86_64 -hda /path/to/os.bin` replacing `/path/to/os.bin` with the path and name of the final binary.