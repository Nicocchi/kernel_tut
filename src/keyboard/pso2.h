#ifndef PSO2_KEYBOARD_H
#define PSO2_KEYBOARD_H

#define PS2_PORT 0x64
#define PS2_CMD_ENABLE_FIRST_PORT 0xAE
#define PS2_KEY_RELEASED 0x80
#define ISR_KEYBOARD_INTERRUPT 0x21
#define KEYBOARD_INPUT_PORT 0x60 // Tells what key is pressed

struct keyboard* pso2_init();

#endif