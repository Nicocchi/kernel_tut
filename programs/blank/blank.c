#include "pandora.h"
#include "stdlib.h"
#include "stdio.h"

int main(int argc, char** argv)
{
    print("I love Nico!\n");
    printf("I really love %i\n", 25);

    void* ptr = malloc(512);
    free(ptr);

    while(1)
    {
        if (getkey() != 0)
        {
            print("key was pressed\n");
        }
    }

    return 0;
}