FindFortran
===========

Finds a fortran compiler, support libraries and companion C/CXX compilers if any.


## Why this repository ?

Waiting the module is integrated in upstream CMake, this repository allows project 
to easily integrate the module by either copying its content or downloading it.

## Integrating the module in your project

Note that this project is under active development. Its API and behavior may change at any time. We mean it.

There are few possible approaches:

### Approach 1: Download

* Add file `cmake/CMakeLists.txt` with the following code used to download the module:

```cmake
# Download FindFortran.cmake
set(dest_file "${CMAKE_CURRENT_BINARY_DIR}/FindFortran.cmake")
set(expected_hash "9072eac4ca2d7a06c6a69cefc315338d322954184a7410892e9afdb2486d9fb7")
set(url "https://raw.githubusercontent.com/scikit-build/cmake-FindVcvars/v1.0/FindFortran.cmake")
if(NOT EXISTS ${dest_file})
  file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
else()
  file(SHA256 ${dest_file} current_hash)
  if(NOT ${current_hash} STREQUAL ${expected_hash})
    file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
  endif()
endif()
```

* Update top-level `CMakeLists.txt` with:

```cmake
add_subdirectory(cmake)
```

* Update `CMAKE_MODULE_PATH`:

```cmake
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_BINARY_DIR}/cmake)
```


### Approach 2: Copy

* Copy `FindFortran.cmake` into your source tree making sure you reference the tag (or SHA) in the associated
  commit message.

* Update `CMAKE_MODULE_PATH`:

```cmake
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
```

### Approach 3: Git submodule

Add this repository as a git submodule.

