#include "pandora.h"

int pandora_getkeyblock()
{
    int val = 0;
    do
    {
        val = pandora_getkey();
    } while (val == 0);
    return val;
}

// Out will be the out buffer
// max - max total chars that can be stored in the out buffer
// output_while_typing - true: displays buffer false: hides buffer
void pandora_terminal_readline(char* out, int max, bool output_while_typing)
{
    int i = 0;
    for (i = 0; i < max - 1; i++)
    {
        char key = pandora_getkeyblock();
        if (key == 13) // Carriage return -> we have read the line
        {
            break;
        }

        if (output_while_typing)
        {
            pandora_putchar(key);
        }

        // Backspace
        if (key == 0x08 && i >= 1)
        {
            out[i - 1] = 0x00;
            i -= 2; // because it will +1 when goign to the continue
            continue;
        }

        out[i] = key;
    }

    out[i] = 0x00; // Add the null terminator
}