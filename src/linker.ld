ENTRY(_star)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 1M; /* Loads kernel 1M into memory at address 0x100000*/
    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}