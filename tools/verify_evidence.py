#!/usr/bin/env python3
"""Parse the archived HPL logs and verify their correctness markers."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

RESULT_RE = re.compile(
    r"^WR\S+\s+(?P<n>\d+)\s+(?P<nb>\d+)\s+(?P<p>\d+)\s+(?P<q>\d+)\s+"
    r"(?P<seconds>[0-9.]+)\s+(?P<gflops>[0-9.eE+-]+)$",
    re.MULTILINE,
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--json", type=Path, help="write parsed results as JSON")
    args = parser.parse_args()

    rows = []
    failures = []
    for path in sorted((args.root / "results").glob("*.log")):
        text = path.read_text(encoding="utf-8", errors="replace")
        match = RESULT_RE.search(text)
        passed = "...... PASSED" in text
        if match is None or not passed:
            failures.append(path.name)
            continue
        row = {key: int(value) if key in {"n", "nb", "p", "q"} else float(value)
               for key, value in match.groupdict().items()}
        row.update(file=path.as_posix(), passed=True)
        rows.append(row)

    if len(rows) != 7:
        failures.append(f"expected 7 valid logs, parsed {len(rows)}")
    best = max(rows, key=lambda item: item["gflops"]) if rows else None
    payload = {"runs": rows, "best": best, "failures": failures}
    if args.json:
        args.json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    for row in rows:
        print(f"{Path(row['file']).name}: PxQ={row['p']}x{row['q']} NB={row['nb']} "
              f"time={row['seconds']:.2f}s GFLOP/s={row['gflops']:.2f} PASSED")
    if best:
        print(f"BEST: {best['gflops']:.2f} GFLOP/s ({Path(best['file']).name})")
    if failures:
        print("FAIL:", "; ".join(failures))
        return 1
    print("PASS: 7/7 HPL logs contain result rows and correctness markers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
