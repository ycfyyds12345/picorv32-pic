ENTRY(_start)
MEMORY { RAM (rwx) : ORIGIN = 0, LENGTH = 64K }
SECTIONS {
 .text : { *(.text.start) *(.text*) } > RAM
 .rodata : { *(.rodata*) } > RAM
 .data : { *(.data*) *(.sdata*) } > RAM
 PROVIDE(__global_pointer$ = . + 0x800);
 .bss (NOLOAD) : { . = ALIGN(4); __bss_start = .; *(.bss*) *(.sbss*) *(COMMON) . = ALIGN(4); __bss_end = .; } > RAM
 /DISCARD/ : { *(.comment) *(.eh_frame*) }
}
