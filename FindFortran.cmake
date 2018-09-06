# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindFortran
-----------

Finds a fortran compiler, support libraries and companion C/CXX compilers if any.

The module can be used when configuring a project or when running
in cmake -P script mode.

These variables must be set to choose which compiler is looked up.

.. variable:: Fortran_COMPILER_ID

  Possible values are any valid Fortran compiler ID.


The module may be used to find different compilers.


Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

.. variable:: Fortran_<Fortran_COMPILER_ID>_IMPLICIT_LINK_LIBRARIES

  List of <Fortran_COMPILER_ID> implicit libraries.

  Setting the variable CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES with this list enables
  imported targets with IMPORTED_LINK_INTERFACE_LANGUAGES property set to Fortran to
  automatically link with these libraries.

.. variable:: Fortran_<Fortran_COMPILER_ID>_RUNTIME_LIBS

  List of <Fortran_COMPILER_ID> runtime libraries.

  These libraries must be distributed along side the compiler code.

#]=======================================================================]

if(NOT DEFINED Fortran_COMPILER_ID)
  message(FATAL_ERROR "Fortran_COMPILER_ID variable must be set")
endif()

# convenient shorter variable name
set(_id ${Fortran_COMPILER_ID})

set(_find_compiler_hints)
if(DEFINED CMAKE_Fortran_COMPILER)
  get_filename_component(fortran_bin_dir ${CMAKE_Fortran_COMPILER} DIRECTORY)
  set(_find_compiler_hints HINTS ${fortran_bin_dir})
endif()

set(_required_vars)

if(_id STREQUAL "Flang")
  find_program(Fortran_${_id}_EXECUTABLE flang ${_find_compiler_hints})

  if(CMAKE_HOST_WIN32)
    get_filename_component(flang_bin_dir ${Fortran_${_id}_EXECUTABLE} DIRECTORY)
    find_program(Fortran_${_id}_CLANG_CL_EXECUTABLE clang-cl.exe HINTS ${flang_bin_dir})
    list(APPEND _required_vars Fortran_${_id}_CLANG_CL_EXECUTABLE)

    # Implicit link libraries
    set(_libs)
    foreach(lib IN ITEMS
      flangmain
      flang
      flangrti
      ompstub
      )
      find_library(Fortran_${_id}_${lib}_LIBRARY ${lib} HINTS ${flang_bin_dir}/../lib)
      list(APPEND _libs ${Fortran_${_id}_${lib}_LIBRARY})
      list(APPEND _required_vars Fortran_${_id}_${lib}_LIBRARY)
    endforeach()
    set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES ${_libs})
    unset(_libs)

    # Runtime libraries
    set(Fortran_${_id}_RUNTIME_LIBS)
    set(_saved_find_library_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
    get_filename_component(runtime_lib_dir ${Fortran_${_id}_EXECUTABLE} DIRECTORY)
    foreach(_lib IN LISTS Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
      get_filename_component(_lib_basename ${_lib} NAME_WE)
      find_library(
        Fortran_${_id}_${_lib_basename}_RUNTIME_LIBRARY ${_lib_basename}
        HINTS ${runtime_lib_dir} NO_DEFAULT_PATH
        )
      if(NOT Fortran_${_id}_${_lib_basename}_RUNTIME_LIBRARY)
        continue()
      endif()
      list(APPEND Fortran_${_id}_RUNTIME_LIBS ${Fortran_${_id}_${_lib_basename}_RUNTIME_LIBRARY})
      list(APPEND _required_vars Fortran_${_id}_${_lib_basename}_RUNTIME_LIBRARY)
    endforeach()
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${_saved_find_library_suffixes})
    unset(_saved_find_library_suffixes)
  endif()

elseif(_id STREQUAL "GNU")
  find_program(Fortran_${_id}_EXECUTABLE gfortran ${_find_compiler_hints})

elseif(_id MATCHES "^Intel|SunPro|Cray|G95|PathScale|Absoft|zOS|XL|VisualAge|PGI|HP|NAG$")
  message(FATAL_ERROR "Fortran_COMPILER_ID [${_id}] is not yet supported")

else()
  message(FATAL_ERROR "Fortran_COMPILER_ID [${_id}] is unknown")
endif()

# outputs
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Fortran
  REQUIRED_VARS
    Fortran_${_id}_EXECUTABLE
    ${_required_vars}
)

# clean
unset(_find_compiler_hints)
unset(_id)
unset(_required_vars)

