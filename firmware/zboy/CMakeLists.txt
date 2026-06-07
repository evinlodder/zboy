# SPDX-License-Identifier: Apache-2.0
#
# -----------------------------------------------------------------------------
# Generated with AI assistance by Claude (Anthropic Opus 4.8, model
# claude-opus-4-8) on 2026-06-07. Reviewed and maintained by the project author.
# -----------------------------------------------------------------------------
#
# zboy console firmware — Zephyr application
#
# Directory layout:
#   src/             application code that Zephyr builds
#   include/         headers for everything in src/
#   lib/src          game-side support library sources
#   lib/include      public headers for lib/ (also used by the linker scripts)
#   boards/          devicetree overlays + custom board definitions
#     u575xx/        shared SoC overlay (memory map) — applied for every variant
#     nucleo_u575zi/ overlays for the NUCLEO-U575ZI-Q prototype board
#     u575vi/        custom production board definition (selected with -b u575vi)
#   linker/          linker-script fragments
#     u575xxx/       game memory regions (SRAM2/SRAM3) — applied for every variant
#
# Variant selection (board + overlays) is driven by scripts/build.sh, which sets
# BOARD, BOARD_ROOT and EXTRA_DTC_OVERLAY_FILE on the command line.

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(zboy LANGUAGES C ASM)

# --- Include paths -----------------------------------------------------------
# include/ holds headers for src/; lib/include holds the public library headers.
# Absolute paths are required here: relative entries are dropped from the include
# list used to preprocess the linker scripts. (The linker fragment also includes
# mem_defs.h via a path relative to itself, so it does not depend on this.)
zephyr_include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
zephyr_include_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib/include)

# --- Application + library sources --------------------------------------------
file(GLOB app_sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
file(GLOB lib_sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/lib/src/*.c)
target_sources(app PRIVATE ${app_sources} ${lib_sources})

# --- Custom linker sections ---------------------------------------------------
# Injects the GAME_SRAM / GAME_HEAP section layout. The regions themselves are
# created by the memory-region nodes in boards/u575xx/mem.overlay.
zephyr_linker_sources(SECTIONS linker/u575xxx/game_mem.ld)
