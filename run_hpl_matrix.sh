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
mkdir -p "$RESULT_DIR"

run_case() {
  local name=$1 ranks=$2 threads=$3
  local run_dir="$RESULT_DIR/$name"
  mkdir -p "$run_dir"
  cp "$CFG_DIR/${name}.dat" "$run_dir/HPL.dat"
  (
    cd "$run_dir"
    export OMP_NUM_THREADS="$threads"
    export OPENBLAS_NUM_THREADS="$threads"
    export OMP_PROC_BIND=close
    export OMP_PLACES=cores
    /usr/bin/time -v mpirun --bind-to none -np "$ranks" "$HPL_BIN"
  ) 2>&1 | tee "$run_dir/run.log"
}

run_case HPL_1x1_N18000_NB128 1 20
run_case HPL_1x1_N18000_NB256 1 20
run_case HPL_1x2_N18000_NB256 2 10
run_case HPL_1x4_N18000_NB256 4 5
run_case HPL_2x2_N18000_NB192 4 5
run_case HPL_2x2_N18000_NB256 4 5
run_case HPL_2x2_N18000_NB384 4 5
