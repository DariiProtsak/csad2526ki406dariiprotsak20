#!/usr/bin/env bash
set -euo pipefail

echo "CI (POSIX) — creating build directory, configuring, building and running tests"

# ensure build directory exists and enter it
mkdir -p build
cd build

# configure project
cmake ..

# build project
cmake --build .

# run tests via CTest
ctest --output-on-failure

# ensure repository-level build.sh is executable (optional)
if [ -f ../build.sh ]; then
  chmod +x ../build.sh || true
fi

echo "CI (POSIX) finished successfully"
