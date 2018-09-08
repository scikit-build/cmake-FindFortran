cmake_minimum_required(VERSION 3.12)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(Fortran_COMPILER_ID "GNU")
find_package(Fortran REQUIRED)

message(STATUS "Fortran_${Fortran_COMPILER_ID}_RUNTIME_LIBS: ${Fortran_${Fortran_COMPILER_ID}_RUNTIME_LIBS}")

find_package(LAPACKE CONFIG REQUIRED)

add_executable(example_DGELS_rowmajor example_DGELS_rowmajor.c lapacke_example_aux.c lapacke_example_aux.h)
target_link_libraries(example_DGELS_rowmajor lapacke)
