; Contains routines to the kernel
[BITS 32]

section .asm
global print:function
global getkey:function
global pandora_putchar:function
global pandora_malloc:function
global pandora_free:function

; void print(const char* message)
print:
    push ebp
    mov ebp, esp
    push dword[ebp + 8]
    mov eax, 1
    int 0x80
    add esp, 4
    pop ebp
    ret

; int getkey()
getkey:
    push ebp
    mov ebp, esp
    mov eax, 2
    int 0x80
    pop ebp
    ret

; void putchar(char c)
pandora_putchar:
    push ebp
    mov ebp, esp
    mov eax, 3
    push dword[ebp + 8]  ; Variable "c"
    int 0x80
    add esp, 4
    pop ebp
    ret

; void* pandora_malloc(size_t size)
; Allocates memory for this process
pandora_malloc:
    push ebp
    mov ebp, esp
    mov eax, 4
    push dword[ebp + 8] ; Variable "size"
    int 0x80
    add esp, 4
    pop ebp
    ret

; void* pandora_free(void* ptr)
; Frees the allocated memory for this process
pandora_free:
    push ebp
    mov ebp, esp
    mov eax, 5
    push dword[ebp + 8]
    int 0x80
    add esp, 4
    pop ebp
    ret