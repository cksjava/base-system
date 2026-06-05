#!/bin/bash
set -euo pipefail
# Package management (LFS ch.8 §8.2) — narrative only in the book.
# The libfoo/grep tutorial is intentionally not executed; this builder uses
# per-package scripts under stages/ with idempotent .record logs instead.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

echo "Package management: automated via stages/stage{1..4} scripts (no libfoo tutorial)."
