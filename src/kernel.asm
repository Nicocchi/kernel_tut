[BITS 32]

global _start

extern kernel_main

CODE_SEG equ 0x08   ; Code Selector
DATA_SEG equ 0x10   ; Data Selector

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

    ; Remap the master PIC
    mov al, 00010001B       ; Puts the PIC into initialization mode
    out 0x20, al            ; Tell master PIC

    mov al, 0x20            ; Int 0x20 is where master ISR should start 
    out 0x21, al 

    mov al, 0000001B        ; Put the PIC into x86 mode
    out 0x21, al 
    ; End Remap the master PIC
    
    call kernel_main
    jmp $

times 512-($ - $$)db 0      ; Fixes any alignment issues caused by the kernel.asm. 512 % 16 aligns into 16 perfectly
