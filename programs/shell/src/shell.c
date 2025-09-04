#include "shell.h"
#include "stdio.h"
#include "stdlib.h"
#include "pandora.h"

int main(int argc, char** argv)
{
    print("Pandora v1.0.0\n");
    while(1)
    {
        print("> ");
        char buf[1024];
        pandora_terminal_readline(buf, sizeof(buf), true);
        print("\n");
        pandora_process_load_start(buf);
    }
    return 0;
}