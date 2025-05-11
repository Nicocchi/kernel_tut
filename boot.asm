ORG 0x7C00
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop ; Required by the BIOS Parameter Block

; Fake BIOS Parameter Block
times 33 db 0   ; Creates 33 bytes after the short jump


start:
    jmp 0:step2

; Prints the character 'A' to the screen
step2:
    cli                 ; Clear interrupts
    
    ; Segment registers
    mov ax, 0x00
    mov ds, ax
    mov es, ax

    ; Stack segment
    mov ss, ax          ; Set the stack segment now to 0
    mov sp, 0x7C00      ; Stack pointer
    sti                 ; Enable interrupts

.load_protected:
    cli
    ; It will go to the gdt_descriptor, find the size and the offset, look into there and load the gdt_code & gdt_data
    lgdt[gdt_descriptor]    ; Loads the GDT
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32     ; Switches to the code selector and loads load32 - CODE_SEG will be replaced by 0x8

; GDT - Global Descriptor Table
; https://wiki.osdev.org/Global_Descriptor_Table
; These values will be defaults as a paging model is planned to be used. Unlocks all the memory
gdt_start:
gdt_null:   ; Just a null descriptor of 64 bits
    dd 0x0
    dd 0x0

; Offset 0x8 - Where we are about to start to make the code descriptor
gdt_code:           ; CS Should point to this
    dw 0xFFFF       ; Segment limit first 0-15 bits
    dw 0            ; Base first 015 bits
    db 0            ; Base 16-23 bits
    db 0x9A         ; Access byte
    db 11001111b    ; High 4 bit flags and low 4 bit flags
    db 0            ; Base 24-31 bits

; Offset 0x10 - For the data segment, stack segment and so on
gdt_data:           ; DS, SS, ES, FS, GS
    dw 0xFFFF       ; Segment limit first 0-15 bits
    dw 0            ; Base first 015 bits
    db 0            ; Base 16-23 bits
    db 0x92         ; Access byte
    db 11001111b    ; High 4 bit flags and low 4 bit flags
    db 0            ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Gives the size of the descriptor
    dd gdt_start                ; Offset

[BITS 32]
load32:
    ; Load data registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000     ; Set the base pointer to point to 0x00200000
    mov esp, ebp            ; Set the stack pointer to the base pointer - Setting further into memory

    jmp $

times 510-($ - $$)db 0  ; Fill at least 510 bytes of data
dw 0xAA55   ; Intel machines are little indian so the bytes get flipped when working with words. So it becomes '55AA'