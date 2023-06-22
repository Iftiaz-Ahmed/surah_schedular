# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-src"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-build"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/tmp"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src"
  "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "D:/Client/surah_schedular/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
