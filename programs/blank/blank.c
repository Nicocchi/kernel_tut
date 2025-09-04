#include "pandora.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"

int main(int argc, char** argv)
{
    char words[] = "I really love Nico";
    const char* token = strtok(words, " ");

    while (token)
    {
        printf("%s\n", token);
        token = strtok(NULL, " ");
    }
    // printf("I really love Yazawa Nico! %i\n", 25252);

    while(1)
    {
        
    }

    return 0;
}