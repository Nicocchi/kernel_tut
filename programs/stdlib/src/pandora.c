#include "pandora.h"
#include "string.h"

struct command_argument* pandora_parse_command(const char* command, int max)
{
    struct command_argument* root_command = 0;
    char scommand[1025];
    if (max >= (int)sizeof(scommand))
    {
        return 0;
    }

    strncpy(scommand, command, sizeof(scommand));
    
    // Find first token
    char* token = strtok(scommand, " ");
    if (!token)
    {
        goto out;
    }

    // Get first command
    root_command = pandora_malloc(sizeof(struct command_argument));
    if (!root_command)
    {
        goto out;
    }

    strncpy(root_command->argument, token, sizeof(root_command->argument));
    root_command->next = 0;

    // Check if there are any more commands to parse
    struct command_argument* current = root_command;
    token = strtok(NULL, " ");
    while (token != 0)
    {
        struct command_argument* new_command = pandora_malloc(sizeof(struct command_argument));
        if (!new_command)
        {
            break;
        }

        strncpy(new_command->argument, token, sizeof(new_command->argument));
        new_command->next = 0x00;
        current->next = new_command;
        current = new_command;
        token = strtok(NULL, " ");
    }

out:
    return root_command;
}

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

int pandora_system_run(const char* command)
{
    char buf[1024];
    strncpy(buf, command, sizeof(buf));
    struct command_argument* root_command_argument = pandora_parse_command(buf, sizeof(buf));
    if (!root_command_argument)
    {
        return -1;
    }

    return pandora_system(root_command_argument);
}