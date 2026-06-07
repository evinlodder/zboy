/*
 * zboy console firmware — entry point.
 *
 * Placeholder main for bring-up. Including mem_defs.h here compiles the memory
 * budget _Static_assert checks in a C context (the same header is also consumed
 * by the linker script, where those asserts are skipped).
 */

#include <zephyr/kernel.h>

#include <mem_defs.h>

int main(void)
{
	return 0;
}
