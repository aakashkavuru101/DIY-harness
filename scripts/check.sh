#!/bin/sh
# Static checks (docs/spec/06 section 2). Usage: scripts/check.sh [repo-root]
# Prints one line per failure: "check <n>: <file>: <why>". Exits non-zero if any failed.
root=${1:-$(dirname "$0")/..}
CDPATH= cd -- "$root" || { echo "check.sh: cannot enter $root"; exit 2; }
failed=0

report() { echo "check $1: $2: $3"; failed=1; }

# Check 9: three licence texts in vendor/LICENSES/, NOTICE names all three authors.
for name in mattpocock-skills ponytail i-have-adhd; do
  f=vendor/LICENSES/$name
  if [ -L "$f" ]; then report 9 "$f" "is a symlink, must be a copied file"
  elif [ ! -f "$f" ] || [ ! -s "$f" ]; then report 9 "$f" "licence text missing or empty"; fi
done
if [ -f NOTICE ]; then
  for author in "Matt Pocock" "DietrichGebert" "Ayoub Ghriss"; do
    # "by <author>" so the repo slug DietrichGebert/ponytail alone does not count as credit
    grep -qwF "by $author" NOTICE || report 9 NOTICE "does not credit 'by $author'"
  done
else
  report 9 NOTICE "missing"
fi

exit "$failed"
