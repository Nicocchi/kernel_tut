ORG 0
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

_start:
    jmp short start
    nop ; Required by the BIOS Parameter Block

; Fake BIOS Parameter Block
times 33 db 0   ; Creates 33 bytes after the short jump


start:
    jmp 0x7C0:step2 ; Specifies the segment 0x7C0 so that the code segment register gets replaced by 0x7C0

; Handles interrupt 0
handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0eh
    mov al, 'V'
    mov bx, 0x00
    int 0x10
    iret

; Prints the character 'A' to the screen
step2:
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

    ; Each entry in the interrupt table takes up 4 bytes
    ; 2 bytes for offset and 2 bytes for segment
    mov word[ss:0x00], handle_zero  ; Offset. If we don't do stack segment, it'll do the data segment. We want to point to the very first byte in RAM
    mov word[ss:0x02], 0x7C0        ; Segment

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7C0
    
    ; Divide by 0 interrupt -> handle_zero
    mov ax, 0x00
    div ax

    int 1

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

message: db 'Hello World!', 0

times 510-($ - $$)db 0  ; Fill at least 510 bytes of data
dw 0xAA55   ; Intel machines are little indian so the bytes get flipped when working with words. So it becomes '55AA'