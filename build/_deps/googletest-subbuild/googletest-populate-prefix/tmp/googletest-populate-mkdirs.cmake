# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-src"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-build"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/tmp"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/src"
  "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/workspaces/csad2526ki406dariiprotsak20/build/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
