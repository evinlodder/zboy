#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Generated with AI assistance by Claude (Anthropic Opus 4.8, model
# claude-opus-4-8) on 2026-06-07. Reviewed and maintained by the project author.
# -----------------------------------------------------------------------------
#
# Build the zboy console firmware.
#
# Usage:
#   scripts/build.sh [proto|prod] [-p|--pristine] [-- <extra west/cmake args>]
#
#   proto   Build for the NUCLEO-U575ZI-Q prototype board (default).
#           Board: nucleo_u575zi_q/stm32u575xx
#           Overlays: boards/u575xx/*.overlay + boards/nucleo_u575zi/*.overlay
#
#   prod    Build for the custom production board.
#           Board: u575vi (custom definition under boards/u575vi/)
#           Overlays: boards/u575xx/*.overlay + boards/u575vi/*.overlay
#
# Both variants always pull in:
#   - boards/u575xx/*.overlay  (shared SoC memory map)
#   - linker/u575xxx/game_mem.ld via the app CMakeLists
#
# Build output goes to build/<variant>/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FW_DIR="$(dirname "$SCRIPT_DIR")"   # firmware/
APP_DIR="$FW_DIR/zboy"
BUILD_ROOT="$FW_DIR/build"

VARIANT="proto"
PRISTINE=()
EXTRA_ARGS=()

usage() {
	sed -n '9,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		proto|prod)    VARIANT="$1"; shift ;;
		-p|--pristine) PRISTINE=(-p always); shift ;;
		-h|--help)     usage; exit 0 ;;
		--)            shift; EXTRA_ARGS+=("$@"); break ;;
		*)             echo "error: unknown argument '$1'" >&2; usage; exit 1 ;;
	esac
done

# Activate the workspace Python venv if it exists and isn't already active.
if [[ -z "${VIRTUAL_ENV:-}" && -f "$FW_DIR/.venv/bin/activate" ]]; then
	# shellcheck disable=SC1091
	source "$FW_DIR/.venv/bin/activate"
fi

# Collect overlays. nullglob so a missing/empty directory expands to nothing.
shopt -s nullglob
overlays=("$APP_DIR"/boards/u575xx/*.overlay)

case "$VARIANT" in
	proto)
		BOARD="nucleo_u575zi_q/stm32u575xx"
		overlays+=("$APP_DIR"/boards/nucleo_u575zi/*.overlay)
		;;
	prod)
		BOARD="u575vi"
		overlays+=("$APP_DIR"/boards/u575vi/*.overlay)
		;;
esac
shopt -u nullglob

BUILD_DIR="$BUILD_ROOT/$VARIANT"

# Join overlay paths with ';' for EXTRA_DTC_OVERLAY_FILE (appends to, rather
# than replaces, the board's own overlays).
cmake_args=(-DBOARD_ROOT="$APP_DIR")
if [[ ${#overlays[@]} -gt 0 ]]; then
	overlay_list="$(IFS=';'; echo "${overlays[*]}")"
	cmake_args+=(-DEXTRA_DTC_OVERLAY_FILE="$overlay_list")
fi

echo ">> variant : $VARIANT"
echo ">> board   : $BOARD"
echo ">> build   : $BUILD_DIR"
if [[ ${#overlays[@]} -gt 0 ]]; then
	printf '>> overlay : %s\n' "${overlays[@]}"
fi

set -x
west build \
	-b "$BOARD" \
	-d "$BUILD_DIR" \
	-s "$APP_DIR" \
	"${PRISTINE[@]}" \
	"${EXTRA_ARGS[@]}" \
	-- \
	"${cmake_args[@]}"
