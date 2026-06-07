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

#define KB(x) ((x) * 1024)
#define ALIGN_DOWN(x, a) ((x) & ~((a) - 1))

#define SRAM3_SIZE KB(512)    // SRAM3 memory region on U575xxx chips is 512kb
#define SRAM2_SIZE KB(64)     // SRAM2 memory region on U575xxx chips is 64kb
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

// Game code + data sizing -- ensuring it is 8-byte aligned so the stack doesn't
// inflate the size
#define GAME_CODE_SIZE                                                         \
  ALIGN_DOWN(SRAM3_SIZE - GAME_STACK_SIZE - PALETTE_SIZE - FRAMEBUF_TOTAL, 8)

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

#endif // MEM_DEFS_H
