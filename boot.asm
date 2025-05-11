ORG 0
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

jmp 0x7C0:start ; Makes the code segment 0x7C0
; Prints the character 'A' to the screen
start:
    cli                 ; Clear interrupts
    
    ; Segment registers
    ; Since we are setting origin to 0, we are moving the segment registers ourselves to set to 0x7C00
    ; If we don't set these ourselves, and relied on the bios to set them for us, it might set them to
    ; 0x7C0 or might set it to 0 and assume the origin is 0x7C00. We don't know what the registers will be
    ; when we load them.
    mov ax, 0x7C0
    mov ds, ax
    mov es, ax

    ; Stack segment
    mov ax, 0x00
    mov ss, ax          ; Set the stack segment now to 0
    mov sp, 0x7C00      ; Stack pointer
    sti                 ; Enable interrupts

    mov si, message
    call print
    jmp $               ; Keep jumping to itself

print:
    mov bx, 0
.loop:
    lodsb       ; Load the character that the si register is pointing to and load it to the al register and increment the si register
    cmp al, 0
    je .done    ; If equal to 0, jump to done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10    ; Calling the bios video interrupt - Teletype Output
    ret

message: db 'Hello World!', 0   ; ,0 is a null terminator

times 510-($ - $$)db 0  ; Fill at least 510 bytes of data
dw 0xAA55   ; Intel machines are little indian so the bytes get flipped when working with words. So it becomes '55AA'