#!/bin/bash
set -e

# Check if port 5004 is open
if nc -zv -w 1 localhost 5004; then
  echo "Health check passed: port 5004 is open."
  exit 0
else
  echo "Health check failed: port 5004 is not open."
  exit 1
fi
