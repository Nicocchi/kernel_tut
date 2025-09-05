[BITS 32]

global _start
global kernel_registers

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

    ; Remap the master PIC
    mov al, 00010001B       ; ICW1: Puts the PIC into initialization mode
    out 0x20, al            ; Tell master PIC

    mov al, 0x20            ; ICW2: Int 0x20 is where master ISR should start 
    out 0x21, al

    mov al, 0x04            ; ICW3: Tell the Master PIC that there is a slave PIC at IRQ2 (000 0100)
    out 0x21, al

    mov al, 0000001B        ; ICW4: Put the PIC into x86 mode- Enable 8086 mode
    out 0x21, al 
    ; End Remap the master PIC
    
    call kernel_main
    jmp $

kernel_registers:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    ret

times 512-($ - $$)db 0      ; Fixes any alignment issues caused by the kernel.asm. 512 % 16 aligns into 16 perfectly
