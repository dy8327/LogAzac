"""Run the original inspection rules from commit 95207b15d0."""
import os
import sys
from pathlib import Path

if __name__ == '__main__':
    script = Path(__file__).resolve().parent / 'legacy' / 'analyzer.py'
    os.execv(sys.executable, [sys.executable, str(script), *sys.argv[1:]])
