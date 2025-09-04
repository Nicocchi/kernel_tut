#include "stdlib.h"
#include "pandora.h"

// Converts int to string
char* itoa(int i)
{
    static char text[12];   // Declared on global data because it's static
    int loc = 11;
    text[11] = 0;
    char neg = 1;
    if (i >= 0)
    {
        neg = 0;
        i = -i;
    }

    while(i)
    {
        text[--loc] = '0' - (i % 10);
        i /= 10;
    }

    if (loc == 11)
    {
        text[--loc] = '0';
    }

    if (neg)
    {
        text[--loc] = '-';
    }

    return &text[loc];
}

void* malloc(size_t size)
{
    return pandora_malloc(size);
}

void free(void* ptr)
{
    pandora_free(ptr);
}