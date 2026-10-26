#!/usr/bin/env python3
#
# Rebuild binary wrappers without the per-dependency dirs the session already
# searches. The dirs become layers, which the installing profile folds in
# through propagated-user-env-packages.
#
# Inputs come from the derivation's environment: `outputs` and `srcPaths`
# (index-aligned), `pairs`, `exclude`, `extractCmd`, and one variable per
# output naming its path. makeBinaryWrapper is a shell function of the
# builder, which the Nix side exports so the bash children below can call it.

import os
import re
import shutil
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

STORE = os.environ["NIX_STORE"]
EXTRACT_CMD = os.environ["extractCmd"]

# "VAR:relative/dir" pairs the session already searches in the profile.
PAIRS = set(os.environ["pairs"].split())
# Paths left out of the layers, each directly below a searched dir.
EXCLUDE = set(os.environ["exclude"].split())

# A package's own system bus services, systemd units, polkit actions, and
# udev rules start programs outside the session, where nothing searches the
# profile, so those keep their wrappers.
STARTED_OUTSIDE = (
    "share/dbus-1/system-services",
    "lib/systemd/system",
    "etc/systemd/system",
    "share/polkit-1/actions",
    "lib/udev/rules.d",
    "etc/udev/rules.d",
)

# Store paths under these dirs are what moves to the shim.
REWRITTEN_DIRS = ("bin", "sbin", "libexec")

PROPAGATED = "nix-support/propagated-user-env-packages"


def walk_files(root, follow=False):
    """Files below root in a stable order.
    Without `follow` these are `find -type f`: regular files, no symlinks.
    With it, symlinks to files and dirs are followed, like `grep -R`.
    """
    seen = set()

    def walk(directory):
        if follow:
            real = os.path.realpath(directory)
            if real in seen:
                return
            seen.add(real)
        with os.scandir(directory) as it:
            entries = sorted(it, key=lambda e: e.name)
        for e in entries:
            if e.is_dir(follow_symlinks=follow):
                yield from walk(e.path)
            elif e.is_file(follow_symlinks=follow):
                yield e.path

    yield from walk(root)


def read_wrapper(path):
    """argv of the makeCWrapper call embedded in a binary wrapper, else None.

    The first item is the wrapped program. bash does the parsing, because
    the call is quoted for bash.
    """
    out = subprocess.run([EXTRACT_CMD, path], stdout=subprocess.PIPE).stdout
    cmd = os.fsdecode(out).rstrip("\n")
    if not cmd:
        return None
    parsed = subprocess.run(
        ["bash", "-c", 'eval "set -- $1"; printf "%s\\0" "$@"', "bash",
         cmd.removeprefix("makeCWrapper")],
        stdout=subprocess.PIPE, check=True,
    ).stdout
    return [os.fsdecode(a) for a in parsed.split(b"\0")[:-1]]


def make_wrapper(program, wrapper, args):
    subprocess.run(
        ["bash", "-c", 'makeBinaryWrapper "$@"', "bash", program, str(wrapper), *args],
        check=True,
    )


def profile_rel(store_dir):
    """/nix/store/<hash>-name/<rel> -> <rel>, or None."""
    m = re.fullmatch(re.escape(STORE) + r"/[^/]+/(.+)", store_dir)
    return m.group(1) if m else None


def started_outside(srcs):
    """Programs named by the sources' system services, units, rules, actions."""
    named = re.compile(re.escape(STORE.encode()) + rb"/[^\s\"'<>]+")
    found = set()
    for src in srcs:
        for sub in STARTED_OUTSIDE:
            directory = os.path.join(src, sub)
            if not os.path.isdir(directory):
                continue
            for path in walk_files(directory, follow=True):
                try:
                    data = Path(path).read_bytes()
                except OSError:
                    continue
                found.update(os.path.realpath(os.fsdecode(m)) for m in named.findall(data))
    return found


class Shim:
    """One output: `dst` rebuilt from the original output `src`."""

    def __init__(self, src, dst, outside, rewrites):
        self.src = Path(src)
        self.dst = Path(dst)
        self.outside = outside
        self.rewrites = rewrites
        self.layers = set()

    def build(self):
        self.dst.mkdir()
        for child in sorted(self.src.iterdir()):
            (self.dst / child.name).symlink_to(child)
        self.reshim_wrappers()
        self.rewrite_paths()
        self.write_layers()

    def own(self, rel):
        """Make dst/rel replaceable.

        Each symlinked parent dir becomes a real dir of symlinks into src.
        """
        p = self.dst
        for part in Path(rel).parent.parts:
            p = p / part
            if p.is_symlink():
                p.unlink()
                p.mkdir()
                for child in sorted((self.src / p.relative_to(self.dst)).iterdir()):
                    (p / child.name).symlink_to(child)
            elif not p.exists():
                p.mkdir()
        (self.dst / rel).unlink(missing_ok=True)

    def is_flat(self, var, sep, directory):
        """Does the session already search `directory` through `var`?"""
        rel = profile_rel(directory)
        return sep == ":" and rel is not None and f"{var}:{rel}" in PAIRS

    def reshim_wrappers(self):
        files = [p for p in walk_files(self.src) if os.access(p, os.X_OK)]
        with ThreadPoolExecutor() as pool:
            for path, argv in zip(files, pool.map(read_wrapper, files)):
                if argv:
                    self.reshim(path, argv)

    def reshim(self, wrapper, argv):
        if wrapper in self.outside:
            return
        program, args = argv[0], argv[1:]
        rel = Path(wrapper).relative_to(self.src)

        # Drop the dirs the session searches, and remember them as layers.
        kept = []
        i = 0
        while i < len(args):
            if (args[i] in ("--prefix", "--suffix") and i + 3 < len(args)
                    and self.is_flat(*args[i + 1:i + 4])):
                self.layers.add(args[i + 3])
                i += 4
            else:
                kept.append(args[i])
                i += 1

        # KWin trusts a client whose /proc/pid/exe, minus .X-wrapped, is its
        # desktop entry's canonical Exec, which names the shim: the program
        # must be a copy.
        self.own(rel)
        target = self.dst / rel
        if not program.startswith(f"{self.src}/"):
            make_wrapper(program, target, kept)
            return
        program_rel = Path(program).relative_to(self.src)
        if read_wrapper(program):
            make_wrapper(self.dst / program_rel, target, kept)
        elif (kept and all(a == "--inherit-argv0" for a in kept)
              and not re.match(r"\..*-wrapped", rel.name)):
            # A copy named .X-wrapped_ wouldn't unwrap to its desktop entry's name.
            shutil.copy(program, target)
        else:
            self.own(program_rel)
            shutil.copy(program, self.dst / program_rel)
            make_wrapper(self.dst / program_rel, target, kept)

    def rewrite_paths(self):
        """Point text files that name the original's programs at the shim."""
        for path in walk_files(self.src, follow=True):
            try:
                with open(path, "rb") as f:
                    head = f.read(32768)
                    if b"\0" in head:
                        continue
                    data = head + f.read()
            except OSError:
                continue
            if not any(old in data for old, _ in self.rewrites):
                continue
            for old, new in self.rewrites:
                data = data.replace(old, new)
            rel = os.path.relpath(path, self.src)
            self.own(rel)
            (self.dst / rel).write_bytes(data)
            shutil.copymode(path, self.dst / rel)

    def write_layers(self):
        if not self.layers:
            return
        self.own(PROPAGATED)
        original = self.src / PROPAGATED
        propagated = original.read_text().split() if original.exists() else []
        n = 0
        for directory in sorted(self.layers):
            if not os.path.isdir(directory):
                continue
            rel = profile_rel(directory)
            layer = self.dst / "nix-support" / "layers" / str(n)
            n += 1
            target = layer / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            if any(e.startswith(f"{rel}/") for e in EXCLUDE):
                target.mkdir()
                for child in sorted(Path(directory).iterdir()):
                    if f"{rel}/{child.name}" not in EXCLUDE:
                        (target / child.name).symlink_to(child)
            else:
                target.symlink_to(directory)
            propagated.append(str(layer))
        (self.dst / PROPAGATED).write_text(" ".join(propagated) + "\n")


def main():
    outs = os.environ["outputs"].split()
    srcs = os.environ["srcPaths"].split()
    dsts = [os.environ[o] for o in outs]
    outside = started_outside(srcs)
    rewrites = [
        (f"{src}/{d}".encode(), f"{dst}/{d}".encode())
        for src, dst in zip(srcs, dsts)
        for d in REWRITTEN_DIRS
    ]
    for src, dst in zip(srcs, dsts):
        Shim(src, dst, outside, rewrites).build()


if __name__ == "__main__":
    main()
