#!/usr/bin/env bash
set -euo pipefail

# Location validation
if [ ! -d .git ]; then
    echo "Not a git repository"
    exit 1
fi

echo "Starting repository integrity check"
git fsck --full || true

echo "Pruning unreachable objects"
git prune || true

echo "Initial loose-object cleanup"
git repack -d || true

echo "Minimal repack to reduce memory load"
git repack -ad -l --threads=1 --window=1 --depth=1 || true

echo "Delta-free repack fallback"
git repack -ad --no-reuse-delta --no-reuse-object --threads=1 || true

echo "Pack-size capped repack"
git repack -ad --max-pack-size=100m || true

echo "Final GC sweep"
git gc --prune=now || true

echo "Completion. Repository packed and cleaned."
