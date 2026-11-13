#!/usr/bin/env python3
"""Restore the directory/regular-file subset used by the run-59 NAR."""

import os
import pathlib
import struct
import sys


class Reader:
    def __init__(self, stream):
        self.stream = stream

    def value(self):
        size_data = self.stream.read(8)
        if len(size_data) != 8:
            raise ValueError("truncated NAR length")
        size = struct.unpack("<Q", size_data)[0]
        value = self.stream.read(size)
        if len(value) != size:
            raise ValueError("truncated NAR value")
        padding = (-size) % 8
        if self.stream.read(padding) != b"\0" * padding:
            raise ValueError("invalid NAR padding")
        return value

    def word(self, expected=None):
        value = self.value().decode("utf-8")
        if expected is not None and value != expected:
            raise ValueError(f"expected {expected!r}, got {value!r}")
        return value


def safe_child(parent, name):
    if not name or name in (".", "..") or "/" in name or "\0" in name:
        raise ValueError(f"unsafe NAR entry name: {name!r}")
    return parent / name


def restore_node(reader, destination):
    reader.word("(")
    reader.word("type")
    kind = reader.word()
    if kind == "directory":
        destination.mkdir(mode=0o755, parents=True, exist_ok=False)
        while True:
            key = reader.word()
            if key == ")":
                return
            if key != "entry":
                raise ValueError(f"unexpected directory key: {key!r}")
            reader.word("(")
            reader.word("name")
            child = safe_child(destination, reader.word())
            reader.word("node")
            restore_node(reader, child)
            reader.word(")")
    elif kind == "regular":
        executable = False
        key = reader.word()
        if key == "executable":
            reader.word("")
            executable = True
            key = reader.word()
        if key != "contents":
            raise ValueError(f"unexpected regular-file key: {key!r}")
        destination.write_bytes(reader.value())
        destination.chmod(0o555 if executable else 0o444)
        reader.word(")")
    else:
        raise ValueError(f"unsupported NAR node type: {kind!r}")


def main():
    if len(sys.argv) != 3:
        raise SystemExit(f"usage: {sys.argv[0]} INPUT.nar DESTINATION")
    destination = pathlib.Path(sys.argv[2])
    if destination.exists():
        raise SystemExit(f"destination exists: {destination}")
    with open(sys.argv[1], "rb") as stream:
        reader = Reader(stream)
        reader.word("nix-archive-1")
        restore_node(reader, destination)
        if stream.read(1):
            raise ValueError("trailing data after NAR")


if __name__ == "__main__":
    main()
