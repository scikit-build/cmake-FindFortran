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
set(expected_hash "0015895040ea03b55b13ae3924725c1a3d1d9744b7abdf9550e39ba992681f32")
set(url "https://raw.githubusercontent.com/scikit-build/cmake-FindFortran/v0.5.0/FindFortran.cmake")
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

## Maintainers

_These instructions below have been tested on a Linux system, they may have to be adapted to work on macOS or Windows._

### Creating new release and updating README

* Step 1: List all tags sorted by version

```
git fetch --tags && \
  git tag -l | sort -V
```

* Step 2: Choose the next release version number and tag the release

```
tag=vX.Y.Z
git tag -s -m "FindFortran $tag" $tag

git push origin $tag
```

* Step 3: Update release and expected_hash in README

```
cd cmake-FindFortran

expected_hash=$(sha256sum FindFortran.cmake | cut -d" " -f1) && \
sed -E "s/set\(expected_hash.+\)/set\(expected_hash \"$expected_hash\"\)/g" -i README.md && \
sed -E "s/v[0-9](\.[0-9])+\/FindFortran.cmake/$tag\/FindFortran.cmake/g" -i README.md && \
git add README.md && \
git commit -m "README: Update release and expected_hash"

git push origin master
```

