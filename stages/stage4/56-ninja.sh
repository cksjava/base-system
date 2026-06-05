#!/bin/bash
set -euo pipefail
# ninja.html — Ninja-1.13.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="ninja-1.13.2.tar.gz"

lfs_init_package

sed -i '/int Guess/a int   j = 0; char* jobs = getenv( "NINJAJOBS" ); if ( jobs != NULL ) j = atoi( jobs ); if ( j > 0 ) return j; ' src/ninja.cc
python3 configure.py --bootstrap --verbose
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

lfs_finish_package
