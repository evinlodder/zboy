#ifndef MEM_DEFS_H
#define MEM_DEFS_H

/*
 * This header defines important constants
 * for use in the linker script.
 * It defines sizes and ensures that the SRAM3 memory region
 * is not overriden.
 * The sizes of certain regions are intended to be flexible, but still
 * constrained The game code + data region (copied over from cartridge) will be
 * floored at 128kb But the maximum could be much higher depending on the size
 * of the frame buffers
 */

/* Zephyr's sys/util.h also defines KB(); guard to avoid a redefinition warning
 * when this header and Zephyr headers are included together. */
#ifndef KB
#define KB(x) ((x) * 1024)
#endif
#define ALIGN_DOWN(x, a) ((x) & ~((a) - 1))
#define ALIGN_UP(x, a) (((x) + (a) - 1) & ~((a) - 1))

/* The STM32U5 CMSIS SoC header also defines SRAM2_SIZE/SRAM3_SIZE (to the same
 * values); guard to avoid redefinition warnings when included alongside Zephyr
 * headers. The linker pass does not pull in CMSIS, so these still apply there.
 */
#ifndef SRAM3_SIZE
#define SRAM3_SIZE KB(512) // SRAM3 memory region on U575xxx chips is 512kb
#endif
#ifndef SRAM2_SIZE
#define SRAM2_SIZE KB(64) // SRAM2 memory region on U575xxx chips is 64kb
#endif
#define GAME_STACK_SIZE KB(8) // constant stack size for game to use

// Screen size constants
#define SCREEN_W 240
#define SCREEN_H 240
#define SCREEN_BPP 1 // 1-byte indexing

// Frame buffer constants
#define NUM_FRAMEBUFS 2
#define FRAMEBUF_SIZE (SCREEN_W * SCREEN_H * SCREEN_BPP)
#define FRAMEBUF_TOTAL (FRAMEBUF_SIZE * NUM_FRAMEBUFS)

// Palette sizing
#define COLOR_SIZE 2 // RGB565
#define PALETTE_SIZE (256 * COLOR_SIZE)

// Console API function table size
#define API_TABLE_SIZE ALIGN_UP(4, 8)

// Game code + data sizing -- ensuring it is 8-byte aligned so the stack doesn't
// inflate the size
#define GAME_CODE_SIZE                                                         \
  ALIGN_DOWN(SRAM3_SIZE - GAME_STACK_SIZE - PALETTE_SIZE - FRAMEBUF_TOTAL -    \
                 API_TABLE_SIZE,                                               \
             8)

/*
 * Compile-time budget checks. Skipped when this header is pulled into a linker
 * script: the linker preprocessor defines _LINKER, and _Static_assert is a C
 * construct that would otherwise be emitted verbatim into the .ld output. The
 * checks still run whenever a C source (e.g. src/main.c) includes this header.
 */
#ifndef _LINKER

// Assertions to assume nothing breaks
_Static_assert(
    GAME_CODE_SIZE >= KB(128),
    "Game region smaller than desired minimum of 128kb!"); // ensure enough room
                                                           // for game code +
                                                           // data
// Ensure proper region alignment
_Static_assert(
    (FRAMEBUF_SIZE % 4) == 0,
    "Framebuffer size is not 4-byte aligned - check screen dimensions.");
_Static_assert((GAME_CODE_SIZE % 4) == 0,
               "Game code region is not 4-byte aligned - check screen "
               "dimensions and sizes.");
_Static_assert((GAME_STACK_SIZE % 8) == 0,
               "Game stack region is not 8-byte aligned - check stack size.");

// Ensure API_TABLE_SIZE matches the size of the struct
// API_TABLE_SIZE would normally be sizeof() but that isn't available at ld time
#include "console.h"
_Static_assert(API_TABLE_SIZE == ALIGN_UP(sizeof(ConsoleApi), 8),
               "API_TABLE_SIZE doesn't match the size of ConsoleApi! Make sure "
               "to update the macro in mem_defs.h");

#endif // _LINKER

#endif // MEM_DEFS_H
