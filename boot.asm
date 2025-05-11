ORG 0x7C00  ; This is where the bios loads the bootloader
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

; Prints the character 'A' to the screen
start:
    mov si, message
    call print
    jmp $   ; Keep jumping to itself

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