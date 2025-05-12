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

#### Bootloader
```make```

### Run
```make run```