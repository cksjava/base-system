#!/bin/bash
set -euo pipefail
# Python.html — Python-3.14.3 (LFS ch.08, curated override)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="Python-3.14.3.tar.xz"

lfs_init_package

./configure --prefix=/usr \
  --enable-shared \
  --with-system-expat \
  --enable-optimizations \
  --without-static-libpython
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

cat >/etc/pip.conf <<'EOF'
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.14.3/html
tar --strip-components=1 --no-same-owner --no-same-permissions \
  -C /usr/share/doc/python-3.14.3/html \
  -xvf ../python-3.14.3-docs-html.tar.bz2

lfs_finish_package
