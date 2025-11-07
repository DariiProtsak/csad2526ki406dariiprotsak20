# csad2526ki406dariiprotsak20
This repository holds files and materials for CAD laboratory works. It includes sample models and exercises for learning basic computer-aided design skills.

## Build & Test

1. Configure:
   - cmake -S . -B build

2. Build project:
   - cmake --build build -- -j

3. Build only tests (create test executable):
   - cmake --build build --target csad2526ki406dariiprotsak20_tests
   or (convenient target)
   - cmake --build build --target build_tests

4. Run tests:
   - cmake --build build --target run_tests
   or
   - ctest --test-dir build --output-on-failure

These targets are also shown during CMake configure as status messages.
