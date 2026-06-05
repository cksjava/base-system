#!/usr/bin/env python3
"""Parse LFS 13.0-systemd HTML and generate per-package build scripts."""

from __future__ import annotations

import html
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

from parser_rules import (
    DROP_BLOCK_RE,
    DROP_LINE_RE,
    PACKAGE_COMMAND_RULES,
    PACKAGE_TARBALL_OVERRIDES,
    SLUG_WGET_ALIASES,
    STRIP_PART_RES,
)

BOOK = Path(__file__).resolve().parent / "13.0"
OVERRIDES = Path(__file__).resolve().parent / "overrides"
WGET_LIST = BOOK / "wget-list"

ARCHIVE_SUFFIXES = (
    ".tar.xz",
    ".tar.gz",
    ".tar.bz2",
    ".tar.Z",
    ".tgz",
)

CHAPTERS: dict[str, dict] = {
    "05": {"stage": "stage1", "skip": {"introduction"}},
    "06": {"stage": "stage2", "skip": {"introduction"}},
    "07": {
        "stage": "stage3",
        "skip": {
            "introduction",
            "changingowner",
            "kernfs",
            "chroot",
            "creatingdirs",
            "createfiles",
            "cleanup",
        },
    },
    "08": {
        "stage": "stage4",
        "skip": {
            "introduction",
            "pkgmgt",
            "aboutdebug",
            "stripping",
            "cleanup",
        },
    },
}

PHASE_PAGES: list[tuple[str, str, str]] = [
    ("04", "creatingminlayout", "10-create-min-layout"),
    ("04", "addinguser", "11-add-lfs-user"),
    ("04", "settingenvironment", "12-lfs-environment"),
    ("07", "changingowner", "20-change-ownership"),
    ("07", "kernfs", "21-kernfs"),
    ("07", "chroot", "22-enter-chroot"),
    ("07", "creatingdirs", "23-create-dirs"),
    ("07", "createfiles", "24-create-files"),
    ("08", "pkgmgt", "30-pkg-mgmt"),
    ("09", "console", "40-console"),
    ("09", "locale", "41-locale"),
    ("09", "clock", "42-clock"),
    ("09", "network", "43-network"),
    ("10", "fstab", "50-fstab"),
    ("10", "grub", "51-grub"),
]

MAKE_RE = re.compile(r"^make(\s+|$)")

POSTLFS_PHASE_RE = re.compile(r"^(50|[5-9][0-9]|9[0-9])-.*\.sh$")
POSTLFS_LEGACY_REMOVE = ("51-grub.sh",)

_wget_tarballs: list[str] | None = None


@dataclass
class Package:
    chapter: str
    slug: str
    title: str
    stage: str
    commands: list[str] = field(default_factory=list)


def decode_html(text: str) -> str:
    text = html.unescape(text)
    # Only strip real HTML tags (<letter…>), not shell redirection/heredoc (<<).
    text = re.sub(r"</?[a-zA-Z][^>]*>", "", text)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text.strip()


def strip_archive_name(filename: str) -> str:
    for suffix in ARCHIVE_SUFFIXES:
        if filename.endswith(suffix):
            return filename[: -len(suffix)]
    return filename


def load_wget_tarballs() -> list[str]:
    global _wget_tarballs
    if _wget_tarballs is not None:
        return _wget_tarballs
    names: list[str] = []
    if WGET_LIST.is_file():
        for line in WGET_LIST.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            fn = line.rsplit("/", 1)[-1]
            if ".tar." in fn or fn.endswith(".tgz"):
                names.append(fn)
    _wget_tarballs = sorted(names, key=len, reverse=True)
    return _wget_tarballs


def slug_wget_keys(slug: str) -> list[str]:
    """Lookup keys derived from HTML filename (slug), not TOC title."""
    keys: list[str] = []
    base = re.sub(r"-pass\d+$", "", slug, flags=re.IGNORECASE)
    for candidate in (slug, base):
        if candidate not in keys:
            keys.append(candidate)
    for alias in SLUG_WGET_ALIASES.get(slug, SLUG_WGET_ALIASES.get(base, [])):
        if alias not in keys:
            keys.append(alias)
    return keys


def match_wget_tarball(slug: str) -> str | None:
    keys = slug_wget_keys(slug)
    for fn in load_wget_tarballs():
        stem = strip_archive_name(fn)
        stem_lower = stem.lower()
        for key in keys:
            key_lower = key.lower()
            if stem_lower == key_lower:
                return fn
            if stem_lower.startswith(key_lower + "-") or stem_lower.startswith(
                key_lower
            ):
                return fn
    return None


def tarball_from_slug(chapter: str, slug: str) -> str:
    override = PACKAGE_TARBALL_OVERRIDES.get((chapter, slug))
    if override:
        return override
    base_slug = re.sub(r"-pass\d+$", "", slug, flags=re.IGNORECASE)
    override = PACKAGE_TARBALL_OVERRIDES.get((chapter, base_slug))
    if override:
        return override

    matched = match_wget_tarball(slug)
    if matched:
        return matched

    raise ValueError(
        f"No tarball for ch{chapter}/{slug} — add PACKAGE_TARBALL_OVERRIDES "
        f"or SLUG_WGET_ALIASES in parser_rules.py"
    )


def should_drop_line(line: str) -> bool:
    if DROP_LINE_RE.search(line):
        return True
    return False


def clean_command_line(line: str) -> str:
    out = line
    for pat in STRIP_PART_RES:
        out = pat.sub("", out).strip()
    return out


def extract_installation_section(page_html: str) -> str:
    m = re.search(
        r'<div class="installation"[^>]*>(.*?)<div class="content"',
        page_html,
        re.DOTALL | re.IGNORECASE,
    )
    return m.group(1) if m else ""


def extract_commands_from_html(fragment: str) -> list[str]:
    blocks: list[str] = []
    for m in re.finditer(
        r'<pre class="userinput">(.*?)</pre>', fragment, re.DOTALL | re.IGNORECASE
    ):
        raw = decode_html(m.group(1))
        if DROP_BLOCK_RE.search(raw):
            continue
        blocks.append(raw)
    return blocks


HEREDOC_OPEN_RE = re.compile(
    r'^cat\s*(>>)?\s*(\S+)\s*<<-?\s*["\']?(\w+)["\']?\s*$'
)


def normalize_pre_block(block: str) -> str:
    """Book HTML often omits a newline between heredoc openers and body text."""
    block = re.sub(
        r'(<<\s*["\']?EOF["\']?)\s*"',
        r'\1\n"',
        block,
        flags=re.IGNORECASE,
    )
    block = re.sub(
        r'(<<\s*EOF)\s*\[',
        r'\1\n[',
        block,
        flags=re.IGNORECASE,
    )
    return block


def expand_heredoc_commands(lines: list[str]) -> list[str]:
    """Reconstruct cat <<EOF blocks dropped or mangled during HTML extraction."""
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = HEREDOC_OPEN_RE.match(line)
        if m:
            append, target, delim = m.group(1), m.group(2), m.group(3)
            body: list[str] = []
            i += 1
            while i < len(lines):
                if lines[i].strip().strip('"') == delim:
                    i += 1
                    break
                body.append(lines[i])
                i += 1
            op = ">>" if append else ">"
            out.append(f"cat {op}{target} <<'{delim}'")
            out.extend(body)
            out.append(delim)
            continue

        m2 = re.match(r'^cat\s*(>>)?\s*(\S+)\s+"\s*', line)
        if m2:
            append, target = m2.group(1), m2.group(2)
            first = line.split('"', 1)[-1].lstrip()
            body = [first] if first else []
            i += 1
            while i < len(lines) and lines[i].strip() != "EOF":
                body.append(lines[i])
                i += 1
            if i < len(lines) and lines[i].strip() == "EOF":
                i += 1
            op = ">>" if append else ">"
            out.append(f"cat {op}{target} <<'EOF'")
            out.extend(body)
            out.append("EOF")
            continue

        m3 = re.match(r'^cat\s*(>>)?\s*(\S+)\s*\[', line)
        if m3:
            append, target = m3.group(1), m3.group(2)
            body = [line.split("[", 1)[-1].lstrip()]
            body[0] = "[" + body[0]
            i += 1
            while i < len(lines) and lines[i].strip() != "EOF":
                body.append(lines[i])
                i += 1
            if i < len(lines) and lines[i].strip() == "EOF":
                i += 1
            op = ">>" if append else ">"
            out.append(f"cat {op}{target} <<'EOF'")
            out.extend(body)
            out.append("EOF")
            continue

        out.append(line)
        i += 1
    return out


def merge_continued_lines(block: str) -> list[str]:
    """Join book lines continued with trailing backslash before filtering."""
    merged: list[str] = []
    buffer = ""
    for raw in block.split("\n"):
        line = raw.strip()
        if not line or line.startswith("#"):
            if buffer and not buffer.endswith("\\"):
                merged.append(buffer)
                buffer = ""
            continue
        if buffer:
            buffer = buffer.rstrip("\\").rstrip() + " " + line
        else:
            buffer = line
        if not buffer.endswith("\\"):
            merged.append(buffer)
            buffer = ""
    if buffer:
        merged.append(buffer.rstrip("\\").rstrip())
    return merged


def split_commands(block: str) -> list[str]:
    lines: list[str] = []
    block = normalize_pre_block(block)
    for line in expand_heredoc_commands(merge_continued_lines(block)):
        if should_drop_line(line):
            continue
        line = clean_command_line(line)
        if not line:
            continue
        lines.append(line)
    return lines


def parallelize_make(cmd: str) -> str:
    if not MAKE_RE.match(cmd):
        return cmd
    if "-j" in cmd:
        return cmd
    if cmd == "make":
        return 'make -j"${MAKE_JOBS}"'
    return re.sub(r"^make\b", 'make -j"${MAKE_JOBS}"', cmd)


def apply_package_rules(chapter: str, slug: str, commands: list[str]) -> list[str]:
    rules = PACKAGE_COMMAND_RULES.get((chapter, slug), {})
    if not rules:
        return commands

    drop_re = [
        re.compile(p, re.IGNORECASE)
        for p in rules.get("drop_lines_matching", [])
    ]
    drop_prefixes: list[str] = rules.get("drop_lines_starting_with", [])
    append_once: list[str] = rules.get("append_once", [])
    drop_blocks: list[str] = rules.get("drop_blocks_starting_with", [])

    out: list[str] = []
    i = 0
    while i < len(commands):
        cmd = commands[i]

        if any(r.search(cmd) for r in drop_re):
            i += 1
            continue

        if any(cmd.startswith(p) for p in drop_prefixes):
            i += 1
            while i < len(commands) and any(
                commands[i].startswith(p) for p in drop_prefixes
            ):
                i += 1
            for extra in append_once:
                if not any(extra in c for c in out):
                    out.append(extra)
            continue

        if drop_blocks:
            matched_block = False
            for start in drop_blocks:
                if cmd.startswith(start):
                    matched_block = True
                    if start == "cat >" and "EOF" in " ".join(commands[i:]):
                        while i < len(commands) and commands[i] != "EOF":
                            i += 1
                        if i < len(commands):
                            i += 1
                        break
                    if start == "tar -xf ../../tzdata":
                        while i < len(commands):
                            if commands[i].startswith("ln -sfv") and "localtime" in commands[
                                i
                            ]:
                                i += 1
                                break
                            i += 1
                        break
            if matched_block:
                continue

        if "localedata/install-locales" in cmd:
            if any("localedata/install-locales" in c for c in out):
                i += 1
                continue

        out.append(cmd)
        i += 1

    for extra in append_once:
        if not any(extra in c for c in out):
            out.append(extra)

    return out


def transform_commands(chapter: str, slug: str, commands: list[str]) -> list[str]:
    commands = apply_package_rules(chapter, slug, commands)
    out: list[str] = []
    for cmd in commands:
        cmd = parallelize_make(cmd)
        if not out or out[-1] != cmd:
            out.append(cmd)
    return out


def parse_chapter_toc(chapter: str) -> list[tuple[str, str]]:
    toc_path = BOOK / f"chapter{chapter}" / f"chapter{chapter}.html"
    html_text = toc_path.read_text(encoding="utf-8", errors="replace")
    entries: list[tuple[str, str]] = []
    for m in re.finditer(r'<a href="([^"]+\.html)">([^<]+)</a>', html_text):
        href, title = m.group(1), decode_html(m.group(2))
        slug = href.replace(".html", "")
        if slug in CHAPTERS[chapter]["skip"]:
            continue
        entries.append((slug, title))
    return entries


def parse_package(chapter: str, slug: str, title: str) -> Package | None:
    page = BOOK / f"chapter{chapter}" / f"{slug}.html"
    if not page.exists():
        return None
    body = page.read_text(encoding="utf-8", errors="replace")
    section = extract_installation_section(body)
    if not section:
        return None

    commands: list[str] = []
    for block in extract_commands_from_html(section):
        commands.extend(split_commands(block))

    commands = transform_commands(chapter, slug, commands)
    if not commands:
        return None

    return Package(
        chapter=chapter,
        slug=slug,
        title=title,
        stage=CHAPTERS[chapter]["stage"],
        commands=commands,
    )


def script_name(index: int, slug: str) -> str:
    safe = re.sub(r"[^a-zA-Z0-9._-]+", "-", slug).strip("-").lower()
    return f"{index:02d}-{safe}.sh"


def render_package_script(pkg: Package, index: int) -> str:
    tarball = tarball_from_slug(pkg.chapter, pkg.slug)
    lines = [
        "#!/bin/bash",
        "set -euo pipefail",
        f"# {pkg.slug}.html — {pkg.title} (LFS ch.{pkg.chapter}, generated)",
        "",
        'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
        'source "${SCRIPT_DIR}/../../lib/lfs-common.sh"',
        "",
        f'PKG_TARBALL="{tarball}"',
        "",
        "lfs_init_package",
        "",
    ]
    for cmd in pkg.commands:
        lines.append(cmd)
    lines.extend(
        [
            "",
            "lfs_finish_package",
            "",
        ]
    )
    return "\n".join(lines)


def parse_phase_page(chapter: str, slug: str) -> list[str]:
    page = BOOK / f"chapter{chapter}" / f"{slug}.html"
    if not page.exists():
        return []
    body = page.read_text(encoding="utf-8", errors="replace")
    section = extract_installation_section(body)
    if not section:
        m = re.search(
            r'<div class="wrap"[^>]*>(.*)</div>\s*<div class="content"',
            body,
            re.DOTALL,
        )
        if m:
            section = m.group(1)
        else:
            m = re.search(
                r'<div class="sect1"[^>]*>(.*)</div>\s*<div class="navfooter"',
                body,
                re.DOTALL,
            )
            section = m.group(1) if m else body

    commands: list[str] = []
    for block in extract_commands_from_html(section):
        commands.extend(split_commands(block))

    transformed: list[str] = []
    for cmd in commands:
        if slug == "chroot" and "bash --login" in cmd:
            continue
        if slug == "settingenvironment" and "source ~/.bash_profile" in cmd:
            continue
        if should_drop_line(cmd):
            continue
        cmd = clean_command_line(cmd)
        if not cmd:
            continue
        transformed.append(parallelize_make(cmd))
    return transformed


def install_static_postlfs_phases(root: Path) -> None:
    """Copy curated BLFS post-LFS scripts from static/postlfs/ into phases/."""
    import shutil
    import stat

    static = root / "static" / "postlfs"
    phases = root / "phases"
    if not static.is_dir():
        print(f"skip postlfs: missing {static}", file=sys.stderr)
        return

    phases.mkdir(exist_ok=True)
    for legacy in POSTLFS_LEGACY_REMOVE:
        path = phases / legacy
        if path.is_file():
            path.unlink()

    for old in phases.glob("*.sh"):
        if POSTLFS_PHASE_RE.match(old.name):
            old.unlink()

    scripts = sorted(static.glob("*.sh"))
    for src in scripts:
        dest = phases / src.name
        shutil.copy2(src, dest)
        dest.chmod(dest.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    print(f"Installed {len(scripts)} static post-LFS phase scripts from {static}/")


def generate(root: Path) -> None:
    stages = root / "stages"
    phases = root / "phases"
    lib = root / "lib"
    lib.mkdir(exist_ok=True)
    stages.mkdir(exist_ok=True)
    phases.mkdir(exist_ok=True)

    for ch in CHAPTERS:
        stage_dir = stages / CHAPTERS[ch]["stage"]
        stage_dir.mkdir(parents=True, exist_ok=True)
        for old in stage_dir.glob("*.sh"):
            old.unlink()

    pkg_count = 0
    errors: list[str] = []
    for chapter in sorted(CHAPTERS):
        for idx, (slug, title) in enumerate(parse_chapter_toc(chapter), start=1):
            pkg = parse_package(chapter, slug, title)
            if not pkg:
                print(f"skip package (no commands): ch{chapter}/{slug}", file=sys.stderr)
                continue
            name = script_name(idx, slug)
            path = stages / pkg.stage / name
            override = OVERRIDES / pkg.stage / name
            try:
                if override.is_file():
                    path.write_text(override.read_text(encoding="utf-8"), encoding="utf-8")
                else:
                    path.write_text(render_package_script(pkg, idx), encoding="utf-8")
            except ValueError as exc:
                errors.append(f"ch{chapter}/{slug}: {exc}")
                continue
            path.chmod(0o755)
            pkg_count += 1

    install_static_postlfs_phases(root)

    print(f"Generated {pkg_count} package scripts under {stages}/")
    print(f"LFS phases 10–43: edit {phases}/ manually; post-LFS 50+ copied from static/postlfs/")
    if errors:
        for err in errors:
            print(f"ERROR: {err}", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    root = Path(__file__).resolve().parent
    generate(root)


if __name__ == "__main__":
    main()
