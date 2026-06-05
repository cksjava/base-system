"""Rules for lfs_parser.py — edit here to tune filtering and outliers."""

from __future__ import annotations

import re

# --- Package identity: slug (HTML filename stem) → tarball filename ---
# Used when wget-list matching is ambiguous. Extract dir comes from the archive at build time.

PACKAGE_TARBALL_OVERRIDES: dict[tuple[str, str], str] = {
    ("05", "linux-headers"): "linux-6.18.10.tar.xz",
    ("05", "gcc-libstdc++"): "gcc-15.2.0.tar.xz",
    ("06", "binutils-pass2"): "binutils-2.46.0.tar.xz",
    ("06", "gcc-pass2"): "gcc-15.2.0.tar.xz",
    ("05", "binutils-pass1"): "binutils-2.46.0.tar.xz",
    ("05", "gcc-pass1"): "gcc-15.2.0.tar.xz",
    ("07", "Python"): "Python-3.14.3.tar.xz",
    ("08", "Python"): "Python-3.14.3.tar.xz",
    ("08", "sqlite"): "sqlite-autoconf-3510200.tar.gz",
    ("08", "tcl"): "tcl8.6.17-src.tar.gz",
    ("08", "expect"): "expect5.45.4.tar.gz",
    ("08", "xml-parser"): "XML-Parser-2.47.tar.gz",
    ("08", "flit-core"): "flit_core-3.12.0.tar.gz",
    ("08", "markupsafe"): "markupsafe-3.0.3.tar.gz",
    ("08", "libelf"): "elfutils-0.194.tar.bz2",
    ("08", "iana-etc"): "iana-etc-20260202.tar.gz",
    ("08", "man-pages"): "man-pages-6.17.tar.xz",
    ("08", "intltool"): "intltool-0.51.0.tar.gz",
    ("08", "vim"): "vim-9.2.0078.tar.gz",
    ("08", "ninja"): "ninja-1.13.2.tar.gz",
    ("08", "openssl"): "openssl-3.6.1.tar.gz",
    ("08", "systemd"): "systemd-259.1.tar.gz",
    ("08", "meson"): "meson-1.10.1.tar.gz",
    ("08", "groff"): "groff-1.23.0.tar.gz",
    ("08", "less"): "less-692.tar.gz",
    ("08", "dejagnu"): "dejagnu-1.6.3.tar.gz",
}

# Slug → extra wget-list stems to try (after stripping -passN); lowercase matching.
SLUG_WGET_ALIASES: dict[str, list[str]] = {
    "linux-headers": ["linux"],
    "gcc-libstdc++": ["gcc"],
    "libelf": ["elfutils"],
    "xml-parser": ["xml-parser"],
    "flit-core": ["flit_core", "flit-core"],
    "markupsafe": ["markupsafe"],
    "Python": ["python"],
    "sqlite": ["sqlite-autoconf"],
    "tcl": ["tcl8.6.17-src", "tcl"],
    "expect": ["expect5.45.4", "expect"],
    "iana-etc": ["iana-etc"],
    "man-pages": ["man-pages"],
    "intltool": ["intltool"],
    "iproute2": ["iproute2"],
    "util-linux": ["util-linux"],
    "procps-ng": ["procps-ng"],
    "psmisc": ["psmisc"],
    "libpipeline": ["libpipeline"],
    "libxcrypt": ["libxcrypt"],
    "libcap": ["libcap"],
    "pkgconf": ["pkgconf"],
    "pcre2": ["pcre2"],
    "readline": ["readline"],
    "ncurses": ["ncurses"],
    "e2fsprogs": ["e2fsprogs"],
    "man-db": ["man-db"],
    "wheel": ["wheel"],
    "packaging": ["packaging"],
    "setuptools": ["setuptools"],
    "jinja2": ["jinja2"],
    "expat": ["expat"],
    "zlib": ["zlib"],
    "zstd": ["zstd"],
    "lz4": ["lz4"],
    "shadow": ["shadow"],
    "kmod": ["kmod"],
    "kbd": ["kbd"],
    "flex": ["flex"],
    "file": ["file"],
    "gettext": ["gettext"],
    "grub": ["grub"],
    "dbus": ["dbus"],
    "attr": ["attr"],
    "acl": ["acl"],
    "bc": ["bc"],
    "bzip2": ["bzip2"],
}

# =============================================================================
# Book-only commands — documented deny list
# =============================================================================
# The LFS book mixes install steps with narrative examples, post-install admin,
# rescue-media tooling, and configuration handled by curated phase scripts.
# Each entry is (regex, reason). Extend this list when you find bad extractions.
#
# Curated replacements live in:
#   overrides/stage4/     — package tweaks (e.g. glibc locales)
#   phases/40–45, 50–55 — system config and boot (not parsed from HTML)
#   static/postlfs/     — BLFS post-LFS phases

BOOK_ONLY_COMMANDS: list[tuple[str, str]] = [
    # Rescue / optical media (ch.10 grub intro — needs BLFS xorriso)
    (r"^xorriso\b", "rescue ISO tooling — BLFS libisoburn, not in LFS build"),
    (r"^grub-mkrescue\b", "rescue ISO — requires xorriso from BLFS"),
    (r"^cdrecord\b", "optical burn example — host tooling, not chroot build"),
    (r"^wodim\b", "optical burn example — host tooling, not chroot build"),
    (r"^genisoimage\b", "ISO creation example — not part of automated build"),
    # Legacy BIOS boot (replaced by phases/54-grub-efi, 55-grub-boot)
    (r"^grub-install\s+/dev/", "legacy MBR grub-install — use curated GRUB phases"),
    # Glibc locales — use make localedata/install-locales (see overrides/stage4/03-glibc.sh)
    (r"^localedef\b", "per-locale install — use localedata/install-locales instead"),
    # Glibc/gcc maintenance for pre-12.0 systems (not applicable here)
    (r"^DIR=\$\(dirname", "legacy GCC header migration after glibc — not applicable"),
    (r"include-fixed", "legacy GCC fixed-include cleanup — not applicable"),
    # Runtime / post-install admin (curated phase scripts or first boot)
    (r"^ldconfig\b", "runtime loader cache — run at boot or manually, not during build"),
    (r"^tzselect\b", "interactive timezone picker — phases/42-clock.sh uses build.conf"),
    (r"^timedatectl\b", "runtime clock config — phases/42-clock.sh"),
    (r"^localectl\b", "runtime console config — phases/40-console.sh"),
    (r"^hostnamectl\b", "runtime hostname — phases/43-network.sh"),
    (r"^chpasswd\b", "user passwords — phases/44-users.sh"),
    (r"^passwd\b", "interactive password change — phases/44-users.sh"),
    (r"^reboot\b", "post-build admin — not during automated build"),
    (r"^poweroff\b", "post-build admin — not during automated build"),
    (r"^halt\b", "post-build admin — not during automated build"),
    (r"^shutdown\b", "post-build admin — not during automated build"),
    # ch.8 package-management narrative (libfoo tutorial, not a real package)
    (r"libfoo.*deleted", "pkg-mgmt tutorial — diagnosing deleted libraries"),
    (r"^./configure\s+--prefix=/usr/pkg/", "pkg-mgmt tutorial — fake libfoo prefix"),
    (r"DESTDIR=/usr/pkg/", "pkg-mgmt tutorial — fake libfoo DESTDIR"),
    # Diagnostics / exploration (book prose, not build steps)
    (r"^udevadm\b", "device inspection — runtime diagnostic"),
    (r"^modinfo\b", "module inspection — runtime diagnostic"),
    (r"^readelf\b", "binary inspection — test/diagnostic helper"),
    # Boot/kernel steps owned by static postlfs phases
    (r"^mount\s+/boot\b", "kernel/grub install — handled by phases/52–55"),
    (r"^grub-mkconfig\b", "grub.cfg generation — phases/55-grub-boot.sh writes grub.cfg"),
    (r"^echo\s+.*>\s*/etc/os-release", "os-release identity — phases/43-network.sh"),
    (r"^vim\s+-c\s+['\"]:options['\"]", "interactive vim options browser — hangs non-interactive builds"),
]

# Regexes for optional test-suite validation (gcc dummy.log, binutils FAIL grep, etc.)
TEST_VALIDATION_DROP_PATTERNS: list[str] = [
    r"dummy\.log",
    r"test_summary",
    r"testsuite/",
    r"^grep\s+.*FAIL:",
    r"^ulimit -s\s+-H\s+unlimited\b",
    r"testdir/Make_all",
    r"test_plugin_glvs",
]

# Drop entire <pre> blocks when content matches (heredocs, expect scripts, etc.)
DROP_BLOCK_PATTERNS: list[str] = [
    r"spawn\s+make\s+tests",
    r"su\s+-s\s+/usr/bin/expect",
    r"^LC_ALL=.*<<\s*[\"']?EOF",
    # Narrative blocks that must never become scripts
    r"grub-mkrescue",
    r"xorriso",
    r"libfoo.*deleted",
    r"--prefix=/usr/pkg/libfoo",
]

# --- Mechanical build-environment filters (not book narrative) ---
# Test suites are optional in the book; drop any line that runs them, including
# env-prefixed forms (LC_ALL=… make test), make flags (make -k check), and
# su-tester wrappers (often split across '\' continuations — see split_commands).
BUILD_ENV_DROP_PATTERNS: list[str] = [
    r"\bmake\s+(?:\S+\s+)*check\b",
    r"\bmake\s+(?:\S+\s+)*test\b",
    r"\bmake\s+(?:\S+\s+)*test_harness\b",
    r"\bmake\s+(?:\S+\s+)*installcheck\b",
    r"\bninja\s+test\b",
    r"\bunshare\b.*\bninja\s+test\b",
    r"^su\s+tester\b",
    r"\bNON_ROOT_USERNAME=tester\b",
    r"^groupadd\b.*\bdummy\b",
    r"^groupdel\b.*\bdummy\b",
    r"^touch\s+/etc/fstab\s*$",
    r"\bruntest\b",
    r"\bcheck-me\b",
    r"^logout\b",
    r"^source\s+~/.bash_profile",
    r"^exec\s+(/usr/bin/)?bash\b",
    r"^exec\s+env\b.*\bbash\b",
    r"spawn\s+make\s+tests",
    r"^LC_ALL=.*\bsu\s+.*expect",
    r"^chown\s+-R\s+tester\b",
    r"^time\s+\{",
    r"TESTSUITEFLAGS",
    r"^systemctl\b",
    r"^grep\s+[\"']?Timed out",
    r"test-installation",
    r"^touch\s+/etc/ld\.so\.conf",
    r"^rm\s+-f\s+/usr/sbin/nscd",
    r"^install\s+-vm755\s+dest/",
    r"^\[\s*-e\s+.*DIR",
    r"^echo\s+['\"]int main\s*\(\s*\)",
    r"^rm\s+-v.*dummy\.log",
    r"^make\s+-C\s+.*\bcheck\b",
    r"^runtest\.sh\b",
    r"^expect\s+-f\b",
]

# Combined line filter used by lfs_parser.py
DROP_LINE_PATTERNS: list[str] = (
    BUILD_ENV_DROP_PATTERNS
    + TEST_VALIDATION_DROP_PATTERNS
    + [regex for regex, _ in BOOK_ONLY_COMMANDS]
)

# Remove these substrings from a command line (applied after drop-line checks).
STRIP_FROM_LINE: list[str] = [
    r"TESTSUITEFLAGS=-j\S*",
    r"TESTSUITEFLAGS=\"-j[^\"]*\"",
]

# --- Per-package command sequences (applied after generic filters) ---
# Actions:
#   drop_lines_matching: list of regexes
#   drop_lines_starting_with: prefix — drop line and following until a line matches until_regex
#   append_once: command to add if not already present
#   drop_until_matching: (start_prefix, until_regex) — drop from start line until until matches

PACKAGE_COMMAND_RULES: dict[tuple[str, str], dict] = {
    ("08", "glibc"): {
        "drop_lines_matching": [r"^make\s+check"],
        "append_once": ['make -j"${MAKE_JOBS}" localedata/install-locales'],
        "drop_blocks_starting_with": ["cat >", "tar -xf ../../tzdata"],
    },
    ("05", "glibc"): {
        "drop_lines_matching": [
            r"dummy\.log",
            r"^grep\b.*dummy",
            r"^echo\s+['\"]int main",
        ],
    },
}

DROP_LINE_RE = re.compile(
    "|".join(f"(?:{p})" for p in DROP_LINE_PATTERNS),
    re.IGNORECASE,
)
DROP_BLOCK_RE = re.compile(
    "|".join(f"(?:{p})" for p in DROP_BLOCK_PATTERNS),
    re.IGNORECASE,
)
STRIP_PART_RES = [re.compile(p, re.IGNORECASE) for p in STRIP_FROM_LINE]

BOOK_ONLY_RES = [
    (re.compile(regex, re.IGNORECASE), reason) for regex, reason in BOOK_ONLY_COMMANDS
]


def book_only_drop_reason(line: str) -> str | None:
    """Return the reason a line is book-only junk, or None if it may be kept."""
    for pat, reason in BOOK_ONLY_RES:
        if pat.search(line):
            return reason
    return None
