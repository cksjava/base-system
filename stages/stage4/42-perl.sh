#!/bin/bash
set -euo pipefail
# perl.html — Perl-5.42.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="perl-5.42.0.tar.xz"

lfs_init_package

export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -D prefix=/usr -D vendorprefix=/usr -D privlib=/usr/lib/perl5/5.42/core_perl -D archlib=/usr/lib/perl5/5.42/core_perl -D sitelib=/usr/lib/perl5/5.42/site_perl -D sitearch=/usr/lib/perl5/5.42/site_perl -D vendorlib=/usr/lib/perl5/5.42/vendor_perl -D vendorarch=/usr/lib/perl5/5.42/vendor_perl -D man1dir=/usr/share/man/man1 -D man3dir=/usr/share/man/man3 -D pager="/usr/bin/less -isR" -D useshrplib -D usethreads
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
unset BUILD_ZLIB BUILD_BZIP2

lfs_finish_package
