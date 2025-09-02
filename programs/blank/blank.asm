[BITS 32]

section .asm

global _start

; Command 0 SUM
_start:
    push 20
    push 30
    mov eax, 0  ; EAX is used for commands, to tell what command to run and 0 is the command_id
    int 0x80
    add esp, 8  ; 8 is because 4 bytes for 20 and 4 bytes for 30, pushing 8 restores the stack to what it was

    jmp $