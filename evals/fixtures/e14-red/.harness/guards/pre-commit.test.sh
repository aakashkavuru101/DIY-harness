#!/bin/sh
# The pre-commit guard's two tests (QA13): it must block a commit while the check is red, and allow one while it is green.
guard="$(dirname "$0")/pre-commit"
CHECK=false sh "$guard" 2>/dev/null && { echo "must block: a red check let the commit through"; exit 1; }
CHECK=true sh "$guard" || { echo "must allow: a green check refused the commit"; exit 1; }
echo "pre-commit guard: both tests pass"
