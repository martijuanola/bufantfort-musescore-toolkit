#!/usr/bin/env bash
set -euo pipefail

# Only use colors if stdout is a terminal
if [[ -t 1 ]]; then
	RED=$'\033[31m'
	GREEN=$'\033[32m'
	YELLOW=$'\033[33m'
	BLUE=$'\033[34m'
	BOLD=$'\033[1m'
	RESET=$'\033[0m'
else
	RED=''
	GREEN=''
	YELLOW=''
	BLUE=''
	BOLD=''
	RESET=''
fi

usage() {
	cat <<EOF
Usage: $(basename "$0") [-f] [-n] TARGET_DIR [NAME...]

Creates symlinks in TARGET_DIR pointing to entries in ROOT.

  -f        Force: replace existing symlinks (never overwrites real files/dirs)
  -n        Dry run: only print what would be done
  NAME...   Optional list of entries inside ROOT to link (default: all)
EOF
	exit 1
}

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_ROOT/.." && pwd)"

FORCE=0
DRY=0
while getopts ":fnh" opt; do
	case "$opt" in
	f) FORCE=1 ;;
	n) DRY=1 ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))

[[ $# -ge 1 ]] || usage
TARGET="$1"
shift

[[ -d "$ROOT" ]] || {
	echo "Error: root '$ROOT' is not a directory" >&2
	exit 1
}
ROOT="$(cd "$ROOT" && pwd)"
echo "Root directory: ${BOLD}$ROOT${RESET}"

if [[ ! -d "$TARGET" ]]; then
	read -rp "'$TARGET' directory doesn't exist. Create it? [Y/n] " ans
	[[ "$ans" =~ ^[Y]$ ]] || {
		echo "Aborting." >&2
		exit 1
	}
	((DRY)) || mkdir -p "$TARGET"
fi
((DRY)) && [[ ! -d "$TARGET" ]] || TARGET="$(cd "$TARGET" && pwd)"
echo "Target directory: ${BOLD}$TARGET${RESET}"

# # Entries to link: given names, or everything in ROOT (including dotfiles)
# if [[ $# -gt 0 ]]; then
# 	entries=("$@")
# else
# 	entries=()
# 	while IFS= read -r -d '' e; do
# 		entries+=("$(basename "$e")")
# 	done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -print0)
# fi

((DRY)) && echo "${YELLOW}Dry run: no changes will be made${RESET}"
((FORCE)) && echo "${RED}Force mode: existing symlinks will be replaced${RESET}"
read -rp "Press Enter to continue or Ctrl+C to abort..." _
echo "Starting to link entries..."

# Usage: link_entries SRC_DIR DST_DIR NAME...
# Creates a symlink in DST_DIR for each NAME found in SRC_DIR.
link_entries() {
	local src_dir="$1" dst_dir="$2"
	shift 2

	local name src dst
	for name in "$@"; do
		src="$src_dir/$name"
		dst="$dst_dir/$name"

		if [[ -L "$dst" ]]; then
			if ((FORCE)); then
				echo "  ${BLUE}[replace]${RESET} $dst -> $src"
				((DRY)) || ln -sfn "$src" "$dst"
			else
				echo "  ${YELLOW}[skip]${RESET}    $dst already a symlink (use -f)"
			fi
		elif [[ -e "$dst" ]]; then
			echo "  ${RED}[skip]${RESET}    $dst exists and is not a symlink"
		else
			echo "  ${GREEN}[link]${RESET}    $dst -> $src"
			((DRY)) || ln -s "$src" "$dst"
		fi
	done
}

folders=("templates" "styles" "plugins")

for folder in "${folders[@]}"; do
	src_dir="$ROOT/$folder"
	dst_dir="$TARGET/$folder"

	if [[ ! -d "$src_dir" ]]; then
		echo "${YELLOW}[skip]${RESET} $src_dir does not exist"
		continue
	fi

	entries=()
	while IFS= read -r -d '' e; do
		entries+=("$(basename "$e")")
	done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -not -name '.*' -print0 | sort -z) # Avoids copying .dotfiles

	if [[ ${#entries[@]} -eq 0 ]]; then
		echo "No entries found in $src_dir"
		continue
	fi

	echo "${BOLD}Linking entries from $src_dir to $dst_dir...${RESET}"
	((DRY)) || mkdir -p "$dst_dir"
	link_entries "$src_dir" "$dst_dir" "${entries[@]}"
done
