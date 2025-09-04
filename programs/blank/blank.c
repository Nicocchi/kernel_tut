#include "pandora.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"

int main(int argc, char** argv)
{
    char* ptr = malloc(20);
    strcpy(ptr, "yazawa nico");
    print(ptr);
    free(ptr);

    ptr[0] = 'N';
    print("\nabc\n");

    while(1)
    {
        
    }

    return 0;
}