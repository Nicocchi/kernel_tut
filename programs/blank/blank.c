#include "pandora.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"

int main(int argc, char** argv)
{
    while(1)
    {
        printf("%s\n", argv[0]);
    }

    // Exception handling test
    // char* ptr = (char*) 0x00;
    // *ptr = 0x50;

    return 0;
}