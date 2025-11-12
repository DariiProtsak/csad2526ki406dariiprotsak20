@echo off

REM Create POSIX build.sh for other platforms (Linux/macOS/WSL/Git-Bash)
echo Creating build.sh...
>build.sh echo #!/usr/bin/env bash
>>build.sh echo set -e
>>build.sh echo mkdir -p build
>>build.sh echo cd build
>>build.sh echo cmake ..
>>build.sh echo cmake --build .
>>build.sh echo ctest --output-on-failure

REM If bash is available, use POSIX workflow
where bash >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Found bash -> running POSIX build script...
    bash -c "chmod +x build.sh && ./build.sh"
    exit /b %ERRORLEVEL%
)

REM Native Windows flow (cmd)
echo No bash detected -> using native Windows flow...

if not exist build (
    mkdir build
)
cd build

cmake ..
if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed.
    exit /b %ERRORLEVEL%
)

cmake --build .
if %ERRORLEVEL% neq 0 (
    echo Build failed.
    exit /b %ERRORLEVEL%
)

echo ======= RUNNING TESTS =======
ctest --output-on-failure
echo ======= TESTS DONE =======

dir
echo ===========================
dir build
echo ===========================

exit /b %ERRORLEVEL%
