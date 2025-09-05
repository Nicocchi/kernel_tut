#ifndef PROCESS_H
#define PROCESS_H

#include <stdint.h>
#include <stdbool.h>

#include "task.h"
#include "config.h"

#define PROCESS_FILE_TYPE_ELF 0
#define PROCESS_FILE_TYPE_BINARY 1
typedef unsigned char PROCESS_FILE_TYPE;

struct process_allocation
{
    void* ptr;
    size_t size;
};

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

struct process
{
    uint16_t id;
    char filename[PANDORA_MAX_PATH];
    struct task* task; // Main process task
    struct process_allocation allocations[PANDORA_MAX_PROGRAM_ALLOCATIONS]; // The memory (malloc) allocations of the process

    PROCESS_FILE_TYPE filetype;
    union
    {
        void* ptr; // The physical pointer to the process memory
        struct elf_file* elf_file;
    };
    
    void* stack; // The physical pointer to the stack memory
    uint32_t size; // The size of the data pointed to by "ptr"

    struct keyboard_buffer
    {
        char buffer[PANDORA_KEYBOARD_BUFFER_SIZE];
        int head;
        int tail;
    } keyboard;

    struct process_arguments arguments;
};

int process_switch(struct process* process);
int process_load_switch(const char* filename, struct process** process);
int process_load(const char* filename, struct process** process);
int process_load_for_slot(const char* filename, struct process** process, int process_slot);
struct process* process_current();
struct process* process_get(int process_id);
void* process_malloc(struct process* process, size_t size);
void process_free(struct process* process, void* ptr);

void process_get_arguments(struct process* process, int* argc, char*** argv);
int process_inject_arguments(struct process* process, struct command_argument* root_argument);
int process_terminate(struct process* process);

#endif