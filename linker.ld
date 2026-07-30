OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;

  .text : { 
    *(.text) 
  }
  
  .rodata : { 
    *(.rodata) 
  }

  . = ALIGN(16);
  . += 0x1000;
  _stack_top = .;

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame)
    *(.note.*)
  }
}

