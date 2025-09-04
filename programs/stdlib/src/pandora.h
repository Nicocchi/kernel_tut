#ifndef PANDORA_H
#define PANDORA_H

#include <stddef.h>

void print(const char* message);
int getkey();
void* pandora_malloc(size_t size);
void* pandora_free(void* ptr);
int pandora_putchar(int c);

#endif