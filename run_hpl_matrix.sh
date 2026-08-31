#!/usr/bin/env bash
set -euo pipefail

ROOT=/mnt/d/ASC_Final_Selection
HPL_DIR="$ROOT/sources/hpl-2.3/bin/WSL_OpenBLAS"
CFG_DIR="$ROOT/experiments/HPL/configs"
RESULT_DIR="$ROOT/experiments/HPL/results"
mkdir -p "$RESULT_DIR"

run_case() {
  local name="$1" ranks="$2" threads="$3"
  cp "$CFG_DIR/${name}.dat" "$HPL_DIR/HPL.dat"
  (
    cd "$HPL_DIR"
    export OMP_NUM_THREADS="$threads"
    export OPENBLAS_NUM_THREADS="$threads"
    export OMP_PROC_BIND=close
    export OMP_PLACES=cores
    /usr/bin/time -v mpirun --bind-to none -np "$ranks" ./xhpl
  ) 2>&1 | tee "$RESULT_DIR/${name}.log"
}

run_case HPL_1x1_N18000_NB128 1 20
run_case HPL_1x1_N18000_NB256 1 20
run_case HPL_1x2_N18000_NB256 2 10
run_case HPL_2x2_N18000_NB256 4 5
