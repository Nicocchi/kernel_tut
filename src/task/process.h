#ifndef PROCESS_H
#define PROCESS_H

#include <stdint.h>
#include "task.h"
#include "config.h"

struct process
{
    uint16_t id;
    char filename[PANDORA_MAX_PATH];
    struct task* task; // Main process task
    void* allocations[PANDORA_MAX_PROGRAM_ALLOCATIONS]; // The memory (malloc) allocations of the process
    void* ptr; // The physical pointer to the process memory
    void* stack; // The physical pointer to the stack memory
    uint32_t size; // The size of the data pointed to by "ptr"
};

int process_load(const char* filename, struct process** process);
int process_load_for_slot(const char* filename, struct process** process, int process_slot);

#endif