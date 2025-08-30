#include "streamer.h"
#include "memory/heap/kheap.h"
#include "config.h"

struct disk_stream* diskstreamer_new(int disk_id)
{
    struct disk* disk = disk_get(disk_id);
    if (!disk)
    {
        return 0;
    }

    struct disk_stream* streamer = kzalloc(sizeof(struct disk_stream));
    streamer->pos = 0;
    streamer->disk = disk;
    return streamer;
}

int diskstreamer_seek(struct disk_stream* stream, int pos)
{
    stream->pos = pos;
    return 0;
}

// Read from the disk stream, x amount of bytes represented by the total
// and read them into the out pointer.
int diskstreamer_read(struct disk_stream* stream, void* out, int total)
{
    // Calculate sector to be using
    int sector = stream->pos / PANDORA_SECTOR_SIZE;
    int offset = stream->pos % PANDORA_SECTOR_SIZE;
    char buf[PANDORA_SECTOR_SIZE];

    int res = disk_read_block(stream->disk, sector, 1, buf);
    if (res < 0)
    {
        goto out;
    }

    // Calculate total to read
    // Can't load the buffer straight into the out pointer because the out
    // may only hold a buffer for 5 bytes and we can only read 512 bytes at a time.
    // So load the sector into the local buffer var and then loop through the buffer
    // and set the amount to only the amount being asked for so there is never
    // a buffer overflow.
    int total_to_read = total > PANDORA_SECTOR_SIZE ? PANDORA_SECTOR_SIZE : total;
    for (int i = 0; i < total_to_read; i++)
    {
        *(char*)out++ = buf[offset + i];
    }

    // Adjust the stream
    stream->pos += total_to_read;
    if (total > PANDORA_SECTOR_SIZE)
    {
        res = diskstreamer_read(stream, out, total - PANDORA_SECTOR_SIZE);
    }

out:
    return res;
}

void diskstreamer_close(struct disk_stream* stream)
{
    kfree(stream);
}