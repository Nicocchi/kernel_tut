#include "kernel.h"
#include <stddef.h>
#include <stdint.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "string/string.h"
#include "fs/file.h"
#include "disk/disk.h"
#include "fs/pparser.h"
#include "disk/streamer.h"

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

static struct paging_4gb_chunk* kernel_chunk = 0;
void kernel_main()
{
    terminal_initialize();
    print("terminal initialized...\n");
    
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
    
    // Setup paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITEABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);
    
    // Switch to kernel paging chunk
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));
    
    // Enable paging
    enable_paging();
    print("paging enabled...\n");
    
    enable_interrupts();
    print("interrupts enabled...\n\n\n");

    print("\nNico Nico Nii!\nAnata no heart Nico Nico Nii!\n");

    int fd = fopen("0:/nico.txt", "r");
    if (fd)
    {
        struct file_stat s;
        fstat(fd, &s);
        fclose(fd);
        print("closed nico.txt\n");
        // print("\nOpened nico.txt\n");
        // char buf[18];
        // fseek(fd, 2, SEEK_SET);
        // fread(buf, 16, 1, fd);
        // print(buf);
    }
    else
    {
        print("0:/to.txt does not exist\n");
    }
    while (1) {}
}
