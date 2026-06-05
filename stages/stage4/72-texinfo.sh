#!/bin/bash
set -euo pipefail
# texinfo.html — Texinfo-7.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="texinfo-7.2.tar.xz"

lfs_init_package

sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm
./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done
popd

lfs_finish_package
