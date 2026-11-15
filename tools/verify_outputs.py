"""
Validates that all expected figure artifacts (PDF and PNG) exist and are non-empty.
Used in continuous integration to verify complete and correct generator execution.
"""

import sys
from pathlib import Path


def main():
    repo_root = Path(__file__).resolve().parent.parent
    if len(sys.argv) > 1:
        arg_path = Path(sys.argv[1])
        expected_file = arg_path if arg_path.is_absolute() else repo_root / arg_path
    else:
        expected_file = repo_root / "tools" / "expected_outputs.txt"
    
    if not expected_file.exists():
        print(f"Error: Expected outputs list not found: {expected_file}", file=sys.stderr)
        sys.exit(1)
        
    lines = expected_file.read_text(encoding="utf-8").splitlines()
    expected_paths = [line.strip() for line in lines if line.strip() and not line.strip().startswith("#")]
    
    missing = []
    empty = []
    valid = 0
    
    for rel_path in expected_paths:
        full_path = repo_root / rel_path
        if not full_path.exists():
            missing.append(rel_path)
        elif full_path.stat().st_size == 0:
            empty.append(rel_path)
        else:
            valid += 1
            
    print(f"Verified {valid}/{len(expected_paths)} expected output files.")
    
    if missing or empty:
        if missing:
            print(f"Missing {len(missing)} files:", file=sys.stderr)
            for m in missing:
                print(f"  - {m}", file=sys.stderr)
        if empty:
            print(f"Empty (0 bytes) {len(empty)} files:", file=sys.stderr)
            for e in empty:
                print(f"  - {e}", file=sys.stderr)
        sys.exit(1)
        
    print("All expected outputs exist with non-zero file sizes.")


if __name__ == "__main__":
    main()
