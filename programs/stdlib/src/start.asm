[BITS 32]

global _start
extern c_start
extern pandora_process_exit

section .asm

_start:
    call c_start
    call pandora_process_exit
    ret