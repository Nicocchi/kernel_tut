[BITS 32]

section .asm

global restore_general_purpose_registers
global task_return
global user_registers

task_return:
    mov ebp, esp
    ; Push the data segment (SS will be fine)
    ; Push the stack address
    ; Push the flags
    ; Push the code segment
    ; Push the IP

    mov ebx, [ebp + 4]      ; Access the structure passed
    push dword [ebx + 44]   ; Push the data/stack selector
    push dword [ebx + 40]   ; Push the stack pointer
    pushf                   ; Push the flags
    pop eax
    or eax, 0x200
    push eax

    push dword [ebx + 32]   ; Push the code segment
    push dword [ebx + 28]   ; Push the IP to execute
    
    ; Setup segment registers
    mov ax, [ebx + 44]
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword [ebx + 4]
    call restore_general_purpose_registers
    add esp, 4

    iretd                   ; Leave kernel land and execute user land

restore_general_purpose_registers:
    push ebp
    mov ebp, esp
    mov ebx, [ebp + 8]
    mov edi, [ebx]
    mov esi, [ebx + 4]
    mov ebp, [ebx + 8]
    mov edx, [ebx + 16]
    mov ecx, [ebx + 20]
    mov eax, [ebx + 24]
    mov ebx, [ebx + 12]
    pop ebp
    ret

; Sets all the registers back to userland
user_registers:
    mov ax, 0x23
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ret