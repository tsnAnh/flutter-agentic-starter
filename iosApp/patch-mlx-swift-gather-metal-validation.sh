#!/bin/sh
set -eu

PATCH_MARKER='Match Scatter: bind dummy metadata'
RELATIVE_FILE='SourcePackages/checkouts/mlx-swift/Source/Cmlx/mlx/mlx/backend/metal/indexing.cpp'

for derived in "$HOME"/Library/Developer/Xcode/DerivedData/iosApp-*; do
  target="$derived/$RELATIVE_FILE"
  [ -f "$target" ] || continue

  if grep -q "$PATCH_MARKER" "$target"; then
    echo "mlx-swift gather patch already applied: $target"
    exit 0
  fi

  chmod u+w "$target"
  python3 - "$target" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = """  // Set index info
  //
  // We don't need to check for empty idx_shapes because gather has a
  // idx_ndim == 0 specialization
"""
new = """  // Set index info
  if (idx_ndim == 0) {
    // Match Scatter: bind dummy metadata so Metal validation does not see nil
    // vectors for scalar index gathers.
    idx_shapes.push_back(0);
    idx_strides.push_back(0);
    idx_contigs.push_back(false);
  }
"""
if old not in text:
    raise SystemExit(f"mlx-swift gather patch target not found: {path}")
path.write_text(text.replace(old, new))
PY
  echo "Applied mlx-swift gather patch: $target"
  exit 0
done

echo "mlx-swift checkout not found. Open Xcode once or run package resolution, then rerun this script."
