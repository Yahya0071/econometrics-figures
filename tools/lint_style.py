"""
Lint Style and Invariants.
Verifies that tracked files contain:
1. Zero em dashes (\u2014, —).
2. Zero blacklisted AI filler words (delve, pivotal, tapestry, intricate, multifaceted).
"""

import subprocess
import sys
from pathlib import Path


def main():
    repo_root = Path(__file__).resolve().parent.parent
    blacklist = ["delve", "pivotal", "tapestry", "intricate", "multifaceted"]
    violations = []
    
    files = subprocess.check_output(["git", "ls-files"], cwd=repo_root, text=True).splitlines()
    for f in files:
        p = repo_root / f
        if p.is_file() and p.suffix in {".py", ".R", ".do", ".tex", ".md"}:
            text = p.read_text(encoding="utf-8", errors="ignore")
            if "\u2014" in text or "—" in text:
                violations.append(f"Em dash found in {f}")
        if p.is_file() and p.suffix in {".py", ".R", ".do", ".tex"}:
            for word in blacklist:
                if word in text.lower():
                    violations.append(f'Prohibited word "{word}" found in {f}')
                    
    if violations:
        for v in violations:
            print("STYLE VIOLATION:", v, file=sys.stderr)
        sys.exit(1)
        
    print(f"All {len(files)} tracked repository files passed style and vocabulary audit.")


if __name__ == "__main__":
    main()
