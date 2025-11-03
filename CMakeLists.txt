cmake_minimum_required(VERSION 3.26)

project(csad2526ki406dariiprotsak20 LANGUAGES CXX)

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
if(BUILD_TESTING)
    enable_testing()
    file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/tests/*.cpp"
        "${CMAKE_SOURCE_DIR}/tests/*.c"
    )
    if(TEST_SOURCES)
        add_executable(${PROJECT_NAME}_tests ${TEST_SOURCES})
        target_link_libraries(${PROJECT_NAME}_tests PRIVATE Threads::Threads)
        add_test(NAME unit_tests COMMAND ${PROJECT_NAME}_tests)
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