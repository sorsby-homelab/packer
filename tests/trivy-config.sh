#!/usr/bin/env bash
set -euo pipefail

trivy config \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  -q \
  .
