section .asm

extern int21h_handler
extern no_interrupt_handler
extern isr80h_handler
extern interrupt_handler

global idt_load
global no_interrupt
global enable_interrupts
global disable_interrupts
global isr80h_wrapper
global interrupt_pointer_table

enable_interrupts:
    sti
    ret

disable_interrupts:
    cli
    ret

idt_load:
    push ebp
    mov ebp, esp
    mov ebx, [ebp + 8]  ; The pointer provided
    lidt [ebx]
    pop ebp
    ret

no_interrupt:
  pushad
  call no_interrupt_handler
  popad
  iret

%macro interrupt 1
  global int%1
  int%1:
    pushad
    push esp
    push dword %1
    call interrupt_handler
    add esp, 8
    popad
    iret
%endmacro

%assign i 0
%rep 512
  interrupt i
%assign i i+1
%endrep

isr80h_wrapper:
  ; Interrupt frame start
  ; Already pushed by the processor upon entry to this interrupt
  ; uint32_t ip
  ; uint32_t cs
  ; uint32_t flags
  ; uint32_t sp
  ; uint32_t ss
  pushad  ; Pushes the general purpose registers to the stack
  ; Interrupt frame ends
  push esp  ; Push the stack pointer so that it is pointing to the interrupt frame
  push eax  ; Contains the command the kernel should invoke
  call isr80h_handler
  mov dword[tmp_res], eax
  add esp, 8
  
  ; Restore general purposes registers for userland
  popad
  mov eax, [tmp_res]
  iretd

section .data
tmp_res: dd 0 ; Stores the return result from the isr80h_handler

%macro interrupt_array_entry 1
  dd int%1
%endmacro

interrupt_pointer_table:
%assign i 0
%rep 512
  interrupt_array_entry i
%assign i i+1
%endrep