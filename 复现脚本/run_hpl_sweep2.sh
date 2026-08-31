#!/usr/bin/env bash
set -euo pipefail

ROOT=/mnt/d/ASC_Final_Selection
HPL_DIR="$ROOT/sources/hpl-2.3/bin/WSL_OpenBLAS"
CFG_DIR="$ROOT/experiments/HPL/configs"
RESULT_DIR="$ROOT/experiments/HPL/results"

for name in HPL_2x2_N18000_NB192 HPL_2x2_N18000_NB384 HPL_1x4_N18000_NB256; do
  cp "$CFG_DIR/${name}.dat" "$HPL_DIR/HPL.dat"
  (
    cd "$HPL_DIR"
    export OMP_NUM_THREADS=5 OPENBLAS_NUM_THREADS=5
    export OMP_PROC_BIND=close OMP_PLACES=cores
    /usr/bin/time -v mpirun --bind-to none -np 4 ./xhpl
  ) 2>&1 | tee "$RESULT_DIR/${name}.log"
done
