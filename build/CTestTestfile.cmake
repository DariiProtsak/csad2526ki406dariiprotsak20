# CMake generated Testfile for 
# Source directory: /workspaces/csad2526ki406dariiprotsak20
# Build directory: /workspaces/csad2526ki406dariiprotsak20/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test([=[AdditionBasic_PositiveNumbers]=] "/workspaces/csad2526ki406dariiprotsak20/build/csad2526ki406dariiprotsak20_tests" "--gtest_filter=AdditionBasic.PositiveNumbers")
set_tests_properties([=[AdditionBasic_PositiveNumbers]=] PROPERTIES  _BACKTRACE_TRIPLES "/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;85;add_test;/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;0;")
add_test([=[AdditionBasic_ZeroAndMixed]=] "/workspaces/csad2526ki406dariiprotsak20/build/csad2526ki406dariiprotsak20_tests" "--gtest_filter=AdditionBasic.ZeroAndMixed")
set_tests_properties([=[AdditionBasic_ZeroAndMixed]=] PROPERTIES  _BACKTRACE_TRIPLES "/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;86;add_test;/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;0;")
add_test([=[AdditionNegative_BothNegative]=] "/workspaces/csad2526ki406dariiprotsak20/build/csad2526ki406dariiprotsak20_tests" "--gtest_filter=AdditionNegative.BothNegative")
set_tests_properties([=[AdditionNegative_BothNegative]=] PROPERTIES  _BACKTRACE_TRIPLES "/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;87;add_test;/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;0;")
add_test([=[AdditionEdgeCases_IntLimits]=] "/workspaces/csad2526ki406dariiprotsak20/build/csad2526ki406dariiprotsak20_tests" "--gtest_filter=AdditionEdgeCases.IntLimits")
set_tests_properties([=[AdditionEdgeCases_IntLimits]=] PROPERTIES  _BACKTRACE_TRIPLES "/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;88;add_test;/workspaces/csad2526ki406dariiprotsak20/CMakeLists.txt;0;")
subdirs("_deps/googletest-build")
