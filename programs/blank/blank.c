#include "pandora.h"
#include "stdlib.h"
#include "stdio.h"

int main(int argc, char** argv)
{
    print("I love Nico!\n");
    printf("I really love %i\n", 25);

    void* ptr = malloc(512);
    free(ptr);

    char buf[1024];
    pandora_terminal_readline(buf, sizeof(buf), true);
    print(buf);

    while(1)
    {
        
    }

    return 0;
}