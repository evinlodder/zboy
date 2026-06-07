#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Generated with AI assistance by Claude (Anthropic Opus 4.8, model
# claude-opus-4-8) on 2026-06-07. Reviewed and maintained by the project author.
# -----------------------------------------------------------------------------
#
# Flash a previously-built zboy console firmware image.
#
# Usage:
#   scripts/flash.sh [proto|prod] [-- <extra west flash args>]
#
# The flash command itself is the same for every variant — the only thing a
# variant selects is which build directory to flash. So you normally don't need
# to pass anything:
#
#   - no variant given: auto-detect. If only one of build/proto or build/prod
#     exists, flash it. If both exist, flash the most recently built one.
#   - variant given:    flash that specific build (build/<variant>).
#
# Build first with scripts/build.sh. Extra args after -- are passed straight
# through to `west flash` (e.g. --runner openocd, --hex-file ...).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FW_DIR="$(dirname "$SCRIPT_DIR")"   # firmware/
BUILD_ROOT="$FW_DIR/build"

VARIANT=""
EXTRA_ARGS=()

usage() {
	sed -n '9,21p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		proto|prod) VARIANT="$1"; shift ;;
		-h|--help)  usage; exit 0 ;;
		--)         shift; EXTRA_ARGS+=("$@"); break ;;
		*)          echo "error: unknown argument '$1'" >&2; usage; exit 1 ;;
	esac
done

if [[ -n "$VARIANT" ]]; then
	BUILD_DIR="$BUILD_ROOT/$VARIANT"
	if [[ ! -d "$BUILD_DIR" ]]; then
		echo "error: no build at '$BUILD_DIR' — run scripts/build.sh $VARIANT first" >&2
		exit 1
	fi
else
	# Auto-detect: collect existing builds, newest first.
	builds=()
	for v in proto prod; do
		[[ -d "$BUILD_ROOT/$v" ]] && builds+=("$BUILD_ROOT/$v")
	done

	if [[ ${#builds[@]} -eq 0 ]]; then
		echo "error: no builds found under '$BUILD_ROOT' — run scripts/build.sh first" >&2
		exit 1
	fi

	# Most recently modified build directory.
	BUILD_DIR="$(ls -dt "${builds[@]}" | head -n1)"
fi

# Activate the workspace Python venv if it exists and isn't already active.
if [[ -z "${VIRTUAL_ENV:-}" && -f "$FW_DIR/.venv/bin/activate" ]]; then
	# shellcheck disable=SC1091
	source "$FW_DIR/.venv/bin/activate"
fi

echo ">> flashing $(basename "$BUILD_DIR") from $BUILD_DIR"
set -x
west flash -d "$BUILD_DIR" "${EXTRA_ARGS[@]}"
