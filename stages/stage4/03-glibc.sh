#!/bin/bash
set -euo pipefail
# Glibc-2.43 final system (LFS chapter 8 — curated override)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="glibc-2.43.tar.xz"

lfs_init_package

patch -Np1 -i ../glibc-fhs-1.patch

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" >configparms

../configure --prefix=/usr \
  --disable-werror \
  --disable-nscd \
  libc_cv_slibdir=/usr/lib \
  --enable-stack-protector=strong \
  --enable-kernel=5.4

make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

make -j"${MAKE_JOBS}" localedata/install-locales

cat >/etc/nsswitch.conf <<'EOF'
passwd: files systemd
group: files systemd
shadow: files systemd
hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
EOF

tar -xf ../../tzdata2025c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv "${ZONEINFO}"/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica \
  asia australasia backward; do
  zic -L /dev/null -d "${ZONEINFO}" "${tz}"
  zic -L /dev/null -d "${ZONEINFO}/posix" "${tz}"
  zic -L leapseconds -d "${ZONEINFO}/right" "${tz}"
done

cp -v zone.tab zone1970.tab iso3166.tab "${ZONEINFO}"
zic -d "${ZONEINFO}" -p America/New_York

ln -sfv ../usr/share/zoneinfo/UTC /etc/localtime

cat >/etc/ld.so.conf <<'EOF'
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
# End /etc/ld.so.conf
EOF

cat >>/etc/ld.so.conf <<'EOF'
include /etc/ld.so.conf.d/*.conf
EOF

mkdir -pv /etc/ld.so.conf.d

lfs_finish_package
