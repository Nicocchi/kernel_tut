#ifndef HEAP_H
#define HEAP_H

#include "config.h"
#include <stdint.h>
#include <stddef.h>

#define HEAP_BLOCK_TABLE_ENTRY_TAKEN 0x01
#define HEAP_BLOCK_TABLE_ENTRY_FREE 0x00

#define HEAP_BLOCK_HAS_NEXT 0B10000000
#define HEAP_BLOCK_IS_FIRST 0B01000000

typedef unsigned char HEAP_BLOCK_TABLE_ENTRY; // 8 bits in the entry table

struct heap_table
{
  HEAP_BLOCK_TABLE_ENTRY* entries;    // Points to the block heap
  size_t total;                       // Amount of total entries
};

struct heap
{
  struct heap_table* table;
  void* saddr;                        // Start address
};

int heap_create(struct heap* heap, void* ptr, void* end, struct heap_table* table);
void* heap_malloc(struct heap* heap, size_t size);
void heap_free(struct heap* heap, void* ptr);

#endif // !HEAP_H
