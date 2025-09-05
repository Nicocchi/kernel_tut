#ifndef PANDORA_H
#define PANDORA_H

#include <stddef.h>
#include <stdbool.h>

struct command_argument
{
    char argument[512];
    struct command_argument* next;
};

struct process_arguments
{
    int argc;
    char** argv;
};

void print(const char* message);
int pandora_getkey();

void* pandora_malloc(size_t size);
void* pandora_free(void* ptr);
int pandora_putchar(int c);

int pandora_getkeyblock();
void pandora_terminal_readline(char* out, int max, bool output_while_typing);
void* pandora_process_load_start(const char* filename);

struct command_argument* pandora_parse_command(const char* command, int max);
void pandora_process_get_arguments(struct process_arguments* arguments);
int pandora_system(struct command_argument* arguments);
int pandora_system_run(const char* command);
void pandora_process_exit();

#endif