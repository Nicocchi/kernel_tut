; Contains routines to the kernel
[BITS 32]

section .asm
global print:function
global pandora_getkey:function
global pandora_putchar:function
global pandora_malloc:function
global pandora_free:function
global pandora_process_load_start:function
global pandora_process_get_arguments:function
global pandora_system:function
global pandora_process_exit:function

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
pandora_getkey:
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

; void pandora_process_load_start(const char* filename)
; Starts a process
pandora_process_load_start:
    push ebp
    mov ebp, esp
    mov eax, 6
    push dword[ebp + 8] ; Variable filename
    int 0x80
    add esp, 4
    pop ebp
    ret

; int pandora_system(struct command_argument* arguments)
; Invokes a system command based on arguments
pandora_system:
    push ebp
    mov ebp, esp
    mov eax, 7
    push dword[ebp + 8] ; Variable arguments
    int 0x80
    add esp, 4
    pop ebp
    ret

; void pandora_process_get_arguments(struct process_arguments* arguments)
; Gets the process arguments
pandora_process_get_arguments:
    push ebp
    mov ebp, esp
    mov eax, 8
    push dword[ebp + 8] ; Variable arguments
    int 0x80
    add esp, 4
    pop ebp
    ret

; void pandora_process_exit()
pandora_process_exit:
    push ebp
    mov ebp, esp
    mov eax, 9
    int 0x80
    pop ebp
    ret