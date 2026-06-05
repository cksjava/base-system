#!/bin/bash
set -euo pipefail
# inetutils.html — Inetutils-2.7 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="inetutils-2.7.tar.gz"

lfs_init_package

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr --bindir=/usr/bin --localstatedir=/var --disable-logger --disable-whois --disable-rcp --disable-rexec --disable-rlogin --disable-rsh --disable-servers
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
mv -v /usr/{,s}bin/ifconfig

lfs_finish_package
