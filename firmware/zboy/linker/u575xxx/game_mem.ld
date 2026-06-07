/*
 * Linker script for the cartridge game's memory regions
 * This is designed for the STM32 U575xxx architecture
 * GAME_HEAP (RW) is a 64kb region that takes up all of SRAM2
 * GAME_SRAM (RWX) is a 512kb region that takes up all of SRAM3
 * Refer to the reference manual for offsets
 *
 * GAME_SRAM memory regions:
 *   0x20040000  ┌──────────────────────────────┐
 *               │  game code + data            │
 *               ├──────────────────────────────┤
 *               │  game stack                  │    8 KB  (0x02000)
 *               ├──────────────────────────────┤
 *               │  framebuffer A  (W*H*BPP)    │
 *               ├──────────────────────────────┤
 *               │  framebuffer B  (W*H*BPP)    │
 *               ├──────────────────────────────┤
 *               │  palette  (256 × RGB565)     │  512 B (using rgb565)
 *               └──────────────────────────────┘
 *               (top of SRAM3: 0x200BFFFF)
 *
 * The size of the framebuffers depends on the screen size defined in lib/include/mem_defs.h
 *  
 * GAME_HEAP memory region:
 *   0x20030000  ┌──────────────────────────────┐
 *               │  game heap                   │   64 KB  (0x10000)
 *   0x20040000  └──────────────────────────────┘
 *

 */

/*
 * Path is relative to this file's directory (linker/u575xxx). The C build finds
 * mem_defs.h via -Ilib/include, but the linker-script preprocessing pass does
 * not get the app's include dirs (they're added after Zephyr snapshots the
 * linker include list), so reference the header by relative path here.
 */
#include "../../lib/include/mem_defs.h"

/* Game code and data */
SECTION_PROLOGUE(game_code, (NOLOAD),)
{
  . = ALIGN(4);
  __game_code_start = .;
  . += GAME_CODE_SIZE;
  __game_code_end = .;
} GROUP_LINK_IN(GAME_SRAM)

/* Game stack */
SECTION_PROLOGUE(game_stack, (NOLOAD),)
{
  . = ALIGN(8); /* ARM ABI requires 8-byte aligned sp */
  __game_stack_bottom = .;
  . += GAME_STACK_SIZE;
  __game_stack_top = .;
} GROUP_LINK_IN(GAME_SRAM)

/* Framebuffer A - back buffer */
SECTION_PROLOGUE(framebuffer_a, (NOLOAD),)
{
  . = ALIGN(4);
  __fb_a_start = .;
  . += FRAMEBUF_SIZE;
  __fb_a_end = .;
} GROUP_LINK_IN(GAME_SRAM)

/* Framebuffer B - front buffer */
SECTION_PROLOGUE(framebuffer_b, (NOLOAD),)
{
  . = ALIGN(4);
  __fb_b_start = .;
  . += FRAMEBUF_SIZE;
  __fb_b_end = .;
} GROUP_LINK_IN(GAME_SRAM)

/* Color palette */ 
SECTION_PROLOGUE(palette, (NOLOAD),)
{
  . = ALIGN(4);
  __palette_start = .;
  . += PALETTE_SIZE;
  __palette_end = .;
} GROUP_LINK_IN(GAME_SRAM)

/* Game heap on SRAM2 */ 
SECTION_PROLOGUE(game_heap, (NOLOAD),)
{
  . = ALIGN(4);
  __game_heap_start = .;
  . += SRAM2_SIZE;
  __game_heap_end = .;
} GROUP_LINK_IN(GAME_HEAP)
