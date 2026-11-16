#!/usr/bin/env python3
"""Assert every exported sh:ValidationReport is internally consistent.

SHACL: a report conforms iff it has no results. For every package listed,
export the whole package as JSON, find every object typed
sh:ValidationReport, and check  sh:conforms == (len(sh:result) == 0).

Usage: python3 tools/check-shacl-reports.py [pkg ...]
"""
import json
import subprocess
import sys

DEFAULT_PKGS = [
    "./examples/course-prereqs",
    "./examples/project-tracker",
    "./examples/recipe-ingredients",
    "./examples/supply-chain",
    "./self-charter",
    "./w3c",
    "./tests/compliance-violation/report-only",
    "./tests/charter-incomplete/report-only",
]


def reports(node, path="$"):
    if isinstance(node, dict):
        t = node.get("@type")
        if t == "sh:ValidationReport" or (isinstance(t, list) and "sh:ValidationReport" in t):
            yield path, node
        for k, v in node.items():
            yield from reports(v, f"{path}.{k}")
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from reports(v, f"{path}[{i}]")


def main(pkgs):
    bad = 0
    total = 0
    for pkg in pkgs:
        out = subprocess.run(["cue", "export", pkg, "--out", "json"],
                             capture_output=True, text=True)
        if out.returncode != 0:
            print(f"FAIL {pkg}: cue export failed\n{out.stderr.strip()}")
            bad += 1
            continue
        for path, r in reports(json.loads(out.stdout)):
            total += 1
            results = r.get("sh:result", [])
            if not isinstance(results, list):
                results = [results]
            conforms = r.get("sh:conforms")
            if conforms != (len(results) == 0):
                print(f"FAIL {pkg} {path}: sh:conforms={conforms} with {len(results)} result(s)")
                bad += 1
    print(f"{total} report(s) checked, {bad} failure(s)")
    if total == 0:
        print("FAIL: no reports found")
        return 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:] or DEFAULT_PKGS))
