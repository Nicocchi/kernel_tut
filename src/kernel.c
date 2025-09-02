#include "kernel.h"
#include <stddef.h>
#include <stdint.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "memory/memory.h"
#include "keyboard/keyboard.h"
#include "string/string.h"
#include "isr80h/isr80h.h"
#include "task/task.h"
#include "task/process.h"
#include "fs/file.h"
#include "disk/disk.h"
#include "fs/pparser.h"
#include "disk/streamer.h"
#include "task/tss.h"
#include "gdt/gdt.h"
#include "config.h"
#include "status.h"

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, char color)
{
    return (color << 8) | c;
}

void terminal_putchar(int x, int y, char c, char color)
{
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
}

void terminal_writechar(char c, char color)
{
    if (c == '\n')
    {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }

    terminal_putchar(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if (terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

// Loops through the terminal and clears it
void terminal_initialize()
{
    video_mem = (uint16_t*)(0xB8000);
    terminal_row = 0;
    terminal_col = 0;

    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

void print(const char* str)
{
    size_t len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        terminal_writechar(str[i], 15);
    }
}

void panic(const char* msg)
{
    print("\n\nUh oh! The kernel has panicked and has halted!\n");
    print(msg);
    while(1) {}
}

static struct paging_4gb_chunk* kernel_chunk = 0;

// Switches the page directory and registers to the kernel page and registers
void kernel_page()
{
    kernel_registers();
    paging_switch(kernel_chunk);
}

struct tss tss;

struct gdt gdt_real[PANDORA_TOTAL_GDT_SEGMENTS];
struct gdt_structured gdt_structured[PANDORA_TOTAL_GDT_SEGMENTS] = {
    {.base = 0x00, .limit = 0x00, .type = 0x00},                     // NULL Segment
    {.base = 0x00, .limit = 0xFFFFFFFF, .type = 0x9A},               // Kernel code segment
    {.base = 0x00, .limit = 0xFFFFFFFF, .type = 0x92},               // Kernel data segment
    {.base = 0x00, .limit = 0xFFFFFFFF, .type = 0xF8},               // User code segment
    {.base = 0x00, .limit = 0xFFFFFFFF, .type = 0xF2},               // User data segment
    {.base = (uint32_t)&tss, .limit = sizeof(tss), .type = 0xE9}     // TSS
};

void kernel_main()
{
    terminal_initialize();
    print("terminal initialized...\n");

    // Load the GDT
    memset(gdt_real, 0x00, sizeof(gdt_real));
    gdt_structured_to_gdt(gdt_real, gdt_structured, PANDORA_TOTAL_GDT_SEGMENTS);
    gdt_load(gdt_real, sizeof(gdt_real));
    print("GDT loaded...\n");
    
    // Initialize the heap
    kheap_init();
    print("heap initialized...\n");

    // Initialize the filesystems
    fs_init();
    print("filesytems initialized...\n");

    // Search and initialize the disk
    disk_search_and_init();
    print("disks found and initialized...\n");
    
    // Initialize the IDT
    idt_init();
    print("IDT initialized...\n");

    // Setup the TSS
    memset(&tss, 0x00, sizeof(tss));
    tss.esp0 = 0x600000;
    tss.ss0 = KERNEL_DATA_SELECTOR;

    // Load the TSS
    tss_load(0x28); // 0x28 is the offset after being loaded in the GDT_REAL
    print("TSS initialized and loaded...\n");
    
    // Setup paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITEABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);
    
    // Switch to kernel paging chunk
    paging_switch(kernel_chunk);
    
    // Enable paging
    enable_paging();
    print("paging enabled...\n");

    // Register the kernel commands
    isr80h_register_commands();
    print("kernel commands registered...\n");

    // Initialize all keyboards
    keyboard_init();
    print("keyboard initialized...\n\n");

    struct process* process = 0;
    int res = process_load_switch("0:/blank.bin", &process);
    if (res != PANDORAOS_ALL_OK)
    {
        panic("kernel: Failed to load blank.bin");
    }

    task_run_first_task();
    
    // enable_interrupts();
    // print("interrupts enabled...\n\n\n");

    while (1) {}
}
