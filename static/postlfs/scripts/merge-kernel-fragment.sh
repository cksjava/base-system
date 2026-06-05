#!/bin/bash
# Enable options from a kernel .config fragment using scripts/config.
set -euo pipefail

fragment="${1:?fragment file required}"
[[ -f .config ]] || { echo ".config missing in $(pwd)" >&2; exit 1; }
[[ -f scripts/config ]] || { echo "scripts/config missing — run from kernel tree" >&2; exit 1; }

while IFS= read -r line || [[ -n "${line}" ]]; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [[ -n "${line}" ]] || continue
  case "${line}" in
    CONFIG_*=y)
      opt="${line#CONFIG_}"
      opt="${opt%=y}"
      ./scripts/config --enable "${opt}"
      ;;
    CONFIG_*=m)
      opt="${line#CONFIG_}"
      opt="${opt%=m}"
      ./scripts/config --module "${opt}"
      ;;
    #CONFIG_*=n) skipped ;;
    *)
      echo "unsupported fragment line: ${line}" >&2
      exit 1
      ;;
  esac
done <"${fragment}"

make olddefconfig
