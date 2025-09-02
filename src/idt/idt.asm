section .asm

extern int21h_handler
extern no_interrupt_handler
extern isr80h_handler

global int21h
global idt_load
global no_interrupt
global enable_interrupts
global disable_interrupts
global isr80h_wrapper

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

int21h:
  pushad
  call int21h_handler
  popad
  iret

no_interrupt:
  pushad
  call no_interrupt_handler
  popad
  iret

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
