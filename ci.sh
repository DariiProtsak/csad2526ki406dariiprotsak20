#!/usr/bin/env bash
set -euo pipefail

echo "CI (POSIX) — creating build directory, configuring, building and running tests"

# видалити старий каталог збірки, щоб уникнути конфліктів CMakeCache
if [ -d build ]; then
  echo "Removing existing build directory..."
  rm -rf build
fi

# створити каталог збірки і перейти в нього
mkdir -p build
cd build

# configure project
echo "Configuring project with CMake..."
cmake ..

# build project
echo "Building project..."
cmake --build .

# run tests via CTest
echo "Running tests via CTest..."
ctest --output-on-failure

# опційно: зробити репозиторний build.sh виконуваним
if [ -f ../build.sh ]; then
  echo "Setting execute permission for ../build.sh"
  chmod +x ../build.sh || true
fi

echo "CI (POSIX) finished successfully"
