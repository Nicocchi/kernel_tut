#include "pso2.h"
#include "keyboard.h"
#include "io/io.h"
#include "kernel.h"
#include "idt/idt.h"
#include "task/task.h"
#include <stdint.h>
#include <stddef.h>

int pso2_keyboard_init();

// https://wiki.osdev.org/PS/2_Keyboard
static uint8_t keyboard_scan_set_one[] = {
    0x00, 0x1B, '1', '2', '3', '4', '5',
    '6', '7', '8', '9', '0', '-', '=',
    0x08, '\t', 'Q', 'W', 'E', 'R', 'T',
    'Y', 'U', 'I', 'O', 'P', '[', ']',
    0x0d, 0x00, 'A', 'S', 'D', 'F', 'G',
    'H', 'J', 'K', 'L', ';', '\'', '`', 
    0x00, '\\', 'Z', 'X', 'C', 'V', 'B',
    'N', 'M', ',', '.', '/', 0x00, '*',
    0x00, 0x20, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, '7', '8', '9', '-', '4', '5', // Numpad
    '6', '+', '1', '2', '3', '0', '.'
};

struct keyboard pso2_keyboard = {
    .name = {"PSO2"},
    .init = pso2_keyboard_init
};

void pso2_keyboard_handle_interrupt();

int pso2_keyboard_init()
{
    idt_register_interrupt_cb(ISR_KEYBOARD_INTERRUPT, pso2_keyboard_handle_interrupt);

    // https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_IO_Ports
    // https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_Commands
    outb(PS2_PORT, PS2_CMD_ENABLE_FIRST_PORT); // Write port/Command register -> Enable first PS/2 port
    return 0;
}

uint8_t pso2_keyboard_scancode_to_char(uint8_t scancode)
{
    size_t size_of_keyboard_set_one = sizeof(keyboard_scan_set_one) / sizeof(uint8_t);
    if (scancode > size_of_keyboard_set_one)
    {
        return 0;
    }

    char c = keyboard_scan_set_one[scancode];
    return c;
}

void pso2_keyboard_handle_interrupt()
{
    kernel_page();
    uint8_t scancode = 0;
    scancode = insb(KEYBOARD_INPUT_PORT); // Reads the scancode
    insb(KEYBOARD_INPUT_PORT); // Ignores the rogue byte

    if (scancode & PS2_KEY_RELEASED)
    {
        return;
    }

    uint8_t c = pso2_keyboard_scancode_to_char(scancode);
    if (c != 0)
    {
        keyboard_push(c);
    }

    task_page();
}

struct keyboard* pso2_init()
{
    return &pso2_keyboard;
}