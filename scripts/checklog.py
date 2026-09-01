#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
# SPDX-License-Identifier: LPPL-1.3c
"""Decide whether a LaTeX build is actually clean.

latexmk exits 0 with undefined references and with text running past the
margin, so the exit status says nothing. This reads the log instead.

Written as a script rather than a shell one-liner because grep is not
always GNU grep: ugrep's -c prints nothing rather than 0 when there is
no match, which in a pipeline reads exactly like success and has hidden
dozens of overfull boxes in a document reported as clean.

Overfull boxes below the threshold are ignored: microtype and
ragged-right typesetting leave a scatter of sub-point overruns that are
invisible on the page.

Usage: checklog.py [-t PT] LOG [LOG ...]
"""

import argparse
import re
import sys


def check(path: str, thresh: float, label: str = "") -> bool:
    """Report on one log; True when it is clean."""
    head = f"{label}:" if label else f"{path}:"
    try:
        log = open(path, errors="replace").read()
    except OSError as exc:
        print(f"{head}\n  cannot read: {exc}")
        return False

    undef = re.findall(r"(?:Reference|Citation) [^\n]*undefined", log)
    boxes = [(float(w), ctx.strip()) for w, ctx in
             re.findall(r"Overfull \\hbox \(([0-9.]+)pt too wide\)[ ]*([^\n]*)",
                        log)]
    big = sorted([b for b in boxes if b[0] >= thresh], reverse=True)

    print(head)
    print(f"  undefined references/citations: {len(undef)}")
    for u in undef[:10]:
        print(f"      {u}")
    print(f"  overfull boxes >= {thresh}pt: {len(big)}  "
          f"(of {len(boxes)} total, rest below threshold)")
    for w, ctx in big[:10]:
        print(f"      {w:.2f}pt  {ctx}")
    if undef or big:
        print("  FAIL")
        return False
    print("  OK: no undefined references, nothing over the margin")
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("logs", nargs="+")
    ap.add_argument("-t", "--threshold", type=float, default=1.0,
                    help="ignore overfull boxes below this many points")
    args = ap.parse_args()
    # Every log is checked before returning, so one bad log does not hide
    # the state of the others.
    ok = [check(p, args.threshold) for p in args.logs]
    return 0 if all(ok) else 1


if __name__ == "__main__":
    sys.exit(main())
