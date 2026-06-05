#!/bin/bash
set -euo pipefail
# perl.html — Perl-5.42.0 (LFS ch.07, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="perl-5.42.0.tar.xz"

lfs_init_package

sh Configure -des -D prefix=/usr -D vendorprefix=/usr -D useshrplib -D privlib=/usr/lib/perl5/5.42/core_perl -D archlib=/usr/lib/perl5/5.42/core_perl -D sitelib=/usr/lib/perl5/5.42/site_perl -D sitearch=/usr/lib/perl5/5.42/site_perl -D vendorlib=/usr/lib/perl5/5.42/vendor_perl -D vendorarch=/usr/lib/perl5/5.42/vendor_perl
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
