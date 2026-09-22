#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
HPL_BIN=${HPL_BIN:-}
CFG_DIR=${CFG_DIR:-"$SCRIPT_DIR/configs"}
RESULT_DIR=${RESULT_DIR:-"$SCRIPT_DIR/reproduced"}

if [[ -z "$HPL_BIN" || ! -x "$HPL_BIN" ]]; then
  echo "Usage: HPL_BIN=/absolute/path/to/xhpl bash $0" >&2
  exit 2
fi

for name in HPL_2x2_N18000_NB192 HPL_2x2_N18000_NB384 HPL_1x4_N18000_NB256; do
  run_dir="$RESULT_DIR/$name"
  mkdir -p "$run_dir"
  cp "$CFG_DIR/${name}.dat" "$run_dir/HPL.dat"
  (
    cd "$run_dir"
    export OMP_NUM_THREADS=5 OPENBLAS_NUM_THREADS=5
    export OMP_PROC_BIND=close OMP_PLACES=cores
    /usr/bin/time -v mpirun --bind-to none -np 4 "$HPL_BIN"
  ) 2>&1 | tee "$run_dir/run.log"
done
