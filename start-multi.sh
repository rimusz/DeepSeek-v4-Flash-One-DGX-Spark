#!/usr/bin/env bash
# Multi-sequence launcher wrapper around upstream start.sh
#
# Defaults (override with env):
#   MAX_NUM_SEQS=8  MAX_MODEL_LEN=256000  SERVING_PORT=8001  DSPARK_TOKENS=5
# CUDA graphs: seqs, 2*seqs, seqs*(K+1)  →  8,16,48 at defaults
#
# Usage:
#   ./start-multi.sh
#   ./start-multi.sh --no-wait
#   MAX_NUM_SEQS=4 ./start-multi.sh
#
# Upstream deep-context profile:
#   MAX_NUM_SEQS=1 MAX_MODEL_LEN=384000 SERVING_PORT=8888 ./start.sh
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

MAX_NUM_SEQS="${MAX_NUM_SEQS:-8}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-256000}"
SERVING_PORT="${SERVING_PORT:-8001}"
DSPARK_TOKENS="${DSPARK_TOKENS:-5}"
MAX_NUM_BATCHED_TOKENS="${MAX_NUM_BATCHED_TOKENS:-8224}"

if [ -z "${MAX_CUDAGRAPH_CAPTURE_SIZE:-}" ]; then
  MAX_CUDAGRAPH_CAPTURE_SIZE=$((MAX_NUM_SEQS * (DSPARK_TOKENS + 1)))
fi
if [ -z "${CUDAGRAPH_CAPTURE_SIZES:-}" ]; then
  CUDAGRAPH_CAPTURE_SIZES="${MAX_NUM_SEQS},$((MAX_NUM_SEQS * 2)),${MAX_CUDAGRAPH_CAPTURE_SIZE}"
fi

# Make compose.yml pick up DSPARK_TOKENS from env (upstream hardcodes "5").
if grep -q 'DSPARK_TOKENS: "5"' ./start.sh 2>/dev/null; then
  sed -i 's/DSPARK_TOKENS: "5"/DSPARK_TOKENS: "${DSPARK_TOKENS:-5}"/' ./start.sh
fi

echo "==> multi-seq profile: seqs=${MAX_NUM_SEQS} len=${MAX_MODEL_LEN} port=${SERVING_PORT} K=${DSPARK_TOKENS} graphs=${CUDAGRAPH_CAPTURE_SIZES}"

export MAX_NUM_SEQS MAX_MODEL_LEN SERVING_PORT DSPARK_TOKENS MAX_NUM_BATCHED_TOKENS
export MAX_CUDAGRAPH_CAPTURE_SIZE CUDAGRAPH_CAPTURE_SIZES

exec ./start.sh "$@"
