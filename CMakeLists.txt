cmake_minimum_required(VERSION 3.26)

project(csad2526ki406dariiprotsak20 LANGUAGES CXX)

# Quick usage shown at configure time
message(STATUS "To configure:  cmake -S . -B build")
message(STATUS "To build:      cmake --build build -- -j")
message(STATUS "To build tests: cmake --build build --target ${PROJECT_NAME}_tests")
message(STATUS "To run tests:  cmake --build build --target run_tests    (or use: ctest --test-dir build --output-on-failure)")

# C++ standard and common options
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(BUILD_TESTING "Enable building tests" ON)
option(BUILD_SHARED_LIBS "Build shared libraries by default" OFF)

# Collect project sources (prefer src/ but fallback to project root)
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/*.c"
    "${CMAKE_SOURCE_DIR}/src/*.cc"
)
if(NOT PROJECT_SOURCES)
    file(GLOB PROJECT_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/*.cpp"
        "${CMAKE_SOURCE_DIR}/*.c"
        "${CMAKE_SOURCE_DIR}/*.cc"
    )
endif()

if(PROJECT_SOURCES)
    add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
    target_include_directories(${PROJECT_NAME} PRIVATE
        "${CMAKE_SOURCE_DIR}/include"
    )
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall -Wextra -Wpedantic
    )
else()
    message(WARNING "No source files found in src/ or project root. Add sources or update CMakeLists.txt.")
endif()

# Link threads if needed
find_package(Threads REQUIRED)
if(TARGET ${PROJECT_NAME})
    target_link_libraries(${PROJECT_NAME} PRIVATE Threads::Threads)
endif()

# Testing (look for tests/ directory)
include(CTest)

# Fetch GoogleTest using FetchContent (only when building tests)
include(FetchContent)
if(BUILD_TESTING)
    FetchContent_Declare(
      googletest
      GIT_REPOSITORY https://github.com/google/googletest.git
      GIT_TAG release-1.14.0
    )
    # Optional: avoid building googletest's own tests
    set(BUILD_GTEST ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    include(GoogleTest)
endif()

if(BUILD_TESTING)
    enable_testing()
    file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/tests/*.cpp"
        "${CMAKE_SOURCE_DIR}/tests/*.c"
    )
    if(TEST_SOURCES)
        add_executable(${PROJECT_NAME}_tests ${TEST_SOURCES})
        target_include_directories(${PROJECT_NAME}_tests PRIVATE
            "${CMAKE_SOURCE_DIR}/include"
            "${CMAKE_SOURCE_DIR}"            # allow including headers from project root
        )
        target_compile_options(${PROJECT_NAME}_tests PRIVATE
            -Wall -Wextra -Wpedantic
        )
        target_link_libraries(${PROJECT_NAME}_tests PRIVATE GTest::gtest_main Threads::Threads)
        # Register tests with CTest
        gtest_discover_tests(${PROJECT_NAME}_tests)

        # convenient targets to build and run tests
        if(TARGET ${PROJECT_NAME}_tests)
            add_custom_target(build_tests
                COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${PROJECT_NAME}_tests
                COMMENT "Build test executable: ${PROJECT_NAME}_tests"
            )

            add_custom_target(run_tests
                DEPENDS ${PROJECT_NAME}_tests
                COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                COMMENT "Run tests via CTest"
            )
        endif()
    endif()
endif()

# Install rules
if(TARGET ${PROJECT_NAME})
    install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
endif()