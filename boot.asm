ORG 0
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

_start:
    jmp short start
    nop ; Required by the BIOS Parameter Block

; Fake BIOS Parameter Block
times 33 db 0   ; Creates 33 bytes after the short jump


start:
    jmp 0x7C0:step2 ; Specifies the segment 0x7C0 so that the code segment register gets replaced by 0x7C0

; DISK - READ SECTOR(S) INTO MEMORY
; https://www.ctyme.com/intr/rb-0607.htm
; AH = 02h
; AL = number of sectors to read (must be nonzero)
; CH = low eight bits of cylinder number
; CL = sector number 1-63 (bits 0-5)
; high two bits of cylinder (bits 6-7, hard disk only)
; DH = head number
; DL = drive number (bit 7 set for hard disk) - Already set for us by the BIOS
; ES:BX -> data buffer

; Return:
; CF set on error
; if AH = 11h (corrected ECC error), AL = burst length
; CF clear if successful
; AH = status (see #00234)
; AL = number of sectors transferred (only valid if CF set for some
; BIOSes)


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

    mov ah, 2   ; Read sector command
    mov al, 1   ; One sector to read
    mov ch, 0   ; Cylinder low eight bits
    mov cl, 2   ; Read sector 2
    mov dh, 0   ; Head number
    mov bx, buffer
    int 0x13    ; Invoke the read command
    jc error    ; If carry flag is set, jump to error

    mov si, buffer
    call print

    jmp $

error:
    mov si, error_message
    call print
    jmp $               ; Keep jumping to itself

print:
    mov bx, 0
.loop:
    lodsb       ; Load the character that the si register is pointing to and load it to the al register and increment the si register
    cmp al, 0   ; Checks for null terminator
    je .done    ; If equal to 0, jump to done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10    ; Calling the bios video interrupt - Teletype Output
    ret

error_message: db 'Failed to load sector', 0

times 510-($ - $$)db 0  ; Fill at least 510 bytes of data
dw 0xAA55   ; Intel machines are little indian so the bytes get flipped when working with words. So it becomes '55AA'

buffer: