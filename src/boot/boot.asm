ORG 0x7C00
BITS 16     ; Use 16bit architecture. Will make sure that the assembler assembles instructions in 16bit code

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


jmp short start
nop ; Required by the BIOS Parameter Block

; FAT16 Header
; https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system
OEMIdentifier               db 'PANDORA '
BytesPerSector              dw 0x200    ; 512, generally ignored by most os
SectorsPerCluster           db 0x80
ReservedSectors             dw 200      ; Reserved for kernel
FATCopies                   db 0x02     ; 2 copies, original and backup
RootDirEntries              dw 0x40
NumSectors                  dw 0x00     ; Not being used
MediaType                   db 0xF8
SectorsPerFat               dw 0x100
SectorsPerTrack             dw 0x20
NumberOfHeads               dw 0x40
HiddenSectors               dd 0x00
SectorsBig                  dd 0x773594

; Extended BPB (Dos 4.0)
DriveNumber                 db 0x80
WinNTBit                    db 0x00
Signature                   db 0x29
VolumeID                    dd 0xD105
VolumeIDString              db 'PANDORABOOT'
SystemIDString              db 'FAT16   '

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

; Load kernel into memory and jump to it
[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000  ; 1M in memory
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax    ; Backup the LBA
    ; Send the highest 8 bits of the LBA to the hard disk controller
    shr eax, 24     ; Shift the reg 24 bits to the right, eax will then contain the highest 8 bits
    or eax, 0xE0    ; Selects the master drive
    mov dx, 0x1F6   ; Port that the bits need to be written to
    out dx, al
    
    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; Sending more bits of the LBA
    mov eax, ebx
    mov dx, 0x1F3
    out dx, al

    mov dx, 0x1F4
    mov eax, ebx    ; Restore the backup LBA
    shr eax, 8
    out dx, al

    ; Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

; Read all sectors into memory
.next_sector:
    push ecx

; Checking if there is a need to read.
; There is a delay sometimes with the controller, and even given the instructions,
; it might not be in a state that is ready to read yet, so keep checking until ready
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again       ; If fails, try again

    ; Read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector   ; Read next sector
    ret

times 510-($ - $$)db 0  ; Fill at least 510 bytes of data
dw 0xAA55   ; Intel machines are little indian so the bytes get flipped when working with words. So it becomes '55AA'