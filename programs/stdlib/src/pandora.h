#ifndef PANDORA_H
#define PANDORA_H

#include <stddef.h>
#include <stdbool.h>

void print(const char* message);
int pandora_getkey();
void* pandora_malloc(size_t size);
void* pandora_free(void* ptr);
int pandora_putchar(int c);

int pandora_getkeyblock();
void pandora_terminal_readline(char* out, int max, bool output_while_typing);

#endif