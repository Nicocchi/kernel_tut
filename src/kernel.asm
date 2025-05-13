[BITS 32]

global _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    ; Load data registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000     ; Set the base pointer to point to 0x00200000
    mov esp, ebp            ; Set the stack pointer to the base pointer - Setting further into memory

    ; Enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $

times 512-($ - $$)db 0      ; Fixes any alignment issues caused by the kernel.asm. 512 % 16 aligns into 16 perfectly