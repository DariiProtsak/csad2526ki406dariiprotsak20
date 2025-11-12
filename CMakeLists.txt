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

# Create a static library from the sources
add_library(${PROJECT_NAME}_lib STATIC ${PROJECT_SOURCES})
target_include_directories(${PROJECT_NAME}_lib PUBLIC
    "${CMAKE_SOURCE_DIR}/include"
)

# <---- Ось тут використовуй крос-компіл флаги ---->
if(MSVC)
    target_compile_options(${PROJECT_NAME}_lib PRIVATE /W4)
else()
    target_compile_options(${PROJECT_NAME}_lib PRIVATE -Wall -Wextra -Wpedantic)
endif()
# <------------------------------------------------>

# Link threads to the library
find_package(Threads REQUIRED)
target_link_libraries(${PROJECT_NAME}_lib PRIVATE Threads::Threads)

# Main executable linking the library
add_executable(hello main.cpp)
target_link_libraries(hello PRIVATE ${PROJECT_NAME}_lib)

# Enable testing early
enable_testing()

# Testing setup
include(FetchContent)
if(BUILD_TESTING)
    FetchContent_Declare(
      googletest
      GIT_REPOSITORY https://github.com/google/googletest.git
      GIT_TAG main
    )
    set(BUILD_GTEST ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)
    include(GoogleTest)
endif()

if(BUILD_TESTING)
    file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/tests/*.cpp"
        "${CMAKE_SOURCE_DIR}/tests/*.c"
    )
    if(TEST_SOURCES)
        add_executable(${PROJECT_NAME}_tests ${TEST_SOURCES})
        target_include_directories(${PROJECT_NAME}_tests PRIVATE
            "${CMAKE_SOURCE_DIR}/include"
            "${CMAKE_SOURCE_DIR}"             # allow including headers from project root
        )
        # <------ Ось тут аналогічний блок флагів ---->
        if(MSVC)
            target_compile_options(${PROJECT_NAME}_tests PRIVATE /W4)
        else()
            target_compile_options(${PROJECT_NAME}_tests PRIVATE -Wall -Wextra -Wpedantic)
        endif()
        # <------------------------------------------>

        target_link_libraries(${PROJECT_NAME}_tests PRIVATE ${PROJECT_NAME}_lib GTest::gtest_main Threads::Threads)

        # Replace automatic discovery with manual add_test registration
        add_test(NAME AdditionBasic_PositiveNumbers COMMAND ${PROJECT_NAME}_tests --gtest_filter=AdditionBasic.PositiveNumbers)
        add_test(NAME AdditionBasic_ZeroAndMixed COMMAND ${PROJECT_NAME}_tests --gtest_filter=AdditionBasic.ZeroAndMixed)
        add_test(NAME AdditionNegative_BothNegative COMMAND ${PROJECT_NAME}_tests --gtest_filter=AdditionNegative.BothNegative)
        add_test(NAME AdditionEdgeCases_IntLimits COMMAND ${PROJECT_NAME}_tests --gtest_filter=AdditionEdgeCases.IntLimits)

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

# Installation rules
if(TARGET hello)
    install(TARGETS hello
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
endif()
