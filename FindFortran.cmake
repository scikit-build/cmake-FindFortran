# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindFortran
-----------

Finds a fortran compiler, support libraries and companion C/CXX compilers if any.

The module can be used when configuring a project or when running
in cmake -P script mode.

These variables may be set to choose which compiler is looked up.

.. variable:: Fortran_COMPILER_ID

  Accepted values are any valid Fortran compiler ID.

  If not already set in the including scope, it is set to the
  :variable:`CMAKE_<LANG>_COMPILER_ID` for Fortran language if
  enabled. If not, it is to the first enabled language beside of Fortran.

The module may be used multiple times to find different compilers.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

.. variable:: Fortran_<Fortran_COMPILER_ID>_IMPLICIT_LINK_LIBRARIES
.. variable:: Fortran_<Fortran_COMPILER_ID>_IMPLICIT_LINK_DIRECTORIES
.. variable:: Fortran_<Fortran_COMPILER_ID>_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES

  List of implicit linking variables associated with ``<Fortran_COMPILER_ID>``.

  If the variables :variable:`CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES`,
  :variable:`CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES`
  and :variable:`CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES` are *NOT* already
  defined in the including project, they will be conveniently initialized by this module
  using the corresponding ``Fortran_<Fortran_COMPILER_ID>_IMPLICIT_LINK_*`` variables.

  Note that setting the ``CMAKE_Fortran_IMPLICIT_LINK_*`` variables ensures that the
  imported targets having the :variable:`IMPORTED_LINK_INTERFACE_LANGUAGES`
  property set to "Fortran" automatically link against the associated libraries.

.. variable:: Fortran_<Fortran_COMPILER_ID>_RUNTIME_LIBRARIES

  List of ``<Fortran_COMPILER_ID>`` runtime libraries.

  These libraries must be distributed along side the compiled binaries. This may be done
  by explicitly using :command:`install` or by setting the variable ``CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS``
  when using :module:`InstallRequiredSystemLibraries` module.

  Libraries expected to be available on most systems are not listed. This applies
  only to unix system where the list was derived from the `manylinux1 policy
  <https://www.python.org/dev/peps/pep-0513/#the-manylinux1-policy>`_. Libraries
  excluded on unix are ``c``, ``crypt``, ``dl``, ``gcc_s``, ``m``, ``nsl``, ``rt``,
  ``util``, ``pthread`` and ``stdc++``.

.. variable:: Fortran_<Fortran_COMPILER_ID>_RUNTIME_DIRECTORIES

  List of directories corresponding to :variable:`Fortran_<Fortran_COMPILER_ID>_RUNTIME_LIBRARIES`.

  This list of directories may be used to configure a launcher.

#]=======================================================================]

function(_fortran_assert)
  if(NOT (${ARGN}))
    message(FATAL_ERROR "assertion error [${ARGN}]")
  endif()
endfunction()

function(_fortran_set_implicit_linking_cache_variables)
  # Caller must defined these variables
  _fortran_assert(DEFINED _id)
  _fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
  _fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)
  _fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)

  if(NOT Fortran_FIND_QUIETLY)
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_LIBRARIES=${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES}")
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES=${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES}")
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES=${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}")
  endif()

  set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES "${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES}" CACHE STRING "${_id} Fortran compiler implicit link libraries")
  mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)

  set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES}" CACHE STRING "${_id} Fortran compiler implicit link directories")
  mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)

  set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}" CACHE STRING "${_id} Fortran compiler implicit link framework directories")
  mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
endfunction()

function(_fortran_retrieve_implicit_link_info)
  # Caller must defined these variables
  _fortran_assert(DEFINED _id)
  _fortran_assert(DEFINED Fortran_${_id}_EXECUTABLE)

  set(_additional_cmake_options ${ARGN})
  if(NOT DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
    set(_desc "Retrieving ${_id} Fortran compiler implicit link info")
    if(NOT Fortran_FIND_QUIETLY)
      message(STATUS ${_desc})
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/CheckFortran${_id})
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/CheckFortran${_id}/CMakeLists.txt"
      "cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(CheckFortran${_id} Fortran)
file(WRITE \"\${CMAKE_CURRENT_BINARY_DIR}/result.cmake\"
\"
set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES \\\"\${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES}\\\")
set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES \\\"\${CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES}\\\")
set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES \\\"\${CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}\\\")
\")
")
    if(CMAKE_GENERATOR_INSTANCE)
      set(_D_CMAKE_GENERATOR_INSTANCE "-DCMAKE_GENERATOR_INSTANCE:INTERNAL=${CMAKE_GENERATOR_INSTANCE}")
    else()
      set(_D_CMAKE_GENERATOR_INSTANCE "")
    endif()
    execute_process(
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/CheckFortran${_id}
      COMMAND ${CMAKE_COMMAND} . -DCMAKE_Fortran_COMPILER:FILEPATH=${Fortran_${_id}_EXECUTABLE}
                                 ${_additional_cmake_options}
                                 -G ${CMAKE_GENERATOR}
                                 -A "${CMAKE_GENERATOR_PLATFORM}"
                                 -T "${CMAKE_GENERATOR_TOOLSET}"
                                 ${_D_CMAKE_GENERATOR_INSTANCE}
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
      RESULT_VARIABLE result
      )
    include(${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/CheckFortran${_id}/result.cmake OPTIONAL)
    if(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES AND "${result}" STREQUAL "0")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "${_desc} passed with the following output:\n"
        "${output}\n")
      if(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
        list(REMOVE_DUPLICATES Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
      endif()
    else()
      set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES NOTFOUND)
      set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES NOTFOUND)
      set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES NOTFOUND)
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "${_desc} failed with the following output:\n"
        "${output}\n")
    endif()
    if(NOT Fortran_FIND_QUIETLY)
      message(STATUS "${_desc} - done")
    endif()
  endif()

  set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES "${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES}" PARENT_SCOPE)
  set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES}" PARENT_SCOPE)
  set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}" PARENT_SCOPE)
endfunction()

function(_fortran_set_runtime_cache_variables)
  # Caller must defined these variables
  _fortran_assert(DEFINED _id)
  _fortran_assert(DEFINED _link_libs)
  _fortran_assert(DEFINED _runtime_lib_dirs)
  _fortran_assert(DEFINED _runtime_lib_suffix)

  if(NOT DEFINED Fortran_${_id}_RUNTIME_LIBRARIES)
    set(CMAKE_FIND_LIBRARY_SUFFIXES "${_runtime_lib_suffix}")

    set(_runtime_libs)
    set(_runtime_dirs)
    foreach(_lib IN LISTS _link_libs)
      get_filename_component(_lib ${_lib} NAME_WE)
      find_library(
        Fortran_${_id}_${_lib}_RUNTIME_LIBRARY ${_lib}
        HINTS ${_runtime_lib_dirs} NO_DEFAULT_PATH
        )
      if(NOT Fortran_${_id}_${_lib}_RUNTIME_LIBRARY)
        unset(Fortran_${_id}_${_lib}_RUNTIME_LIBRARY CACHE) # Do not pollute the project cache
        continue()
      endif()
      list(APPEND _runtime_libs ${Fortran_${_id}_${_lib}_RUNTIME_LIBRARY})

      get_filename_component(_runtime_dir ${Fortran_${_id}_${_lib}_RUNTIME_LIBRARY} DIRECTORY)
      list(APPEND _runtime_dirs ${_runtime_dir})
    endforeach()
    if(_runtime_dirs)
      list(REMOVE_DUPLICATES _runtime_dirs)
    endif()

    set(Fortran_${_id}_RUNTIME_LIBRARIES ${_runtime_libs} CACHE FILEPATH "${_id} Fortran compiler runtime libraries")
    mark_as_advanced(Fortran_${_id}_RUNTIME_LIBRARIES)

    set(Fortran_${_id}_RUNTIME_DIRECTORIES ${_runtime_dirs} CACHE FILEPATH "${_id} Fortran compiler runtime directories")
    mark_as_advanced(Fortran_${_id}_RUNTIME_DIRECTORIES)

    if(NOT Fortran_FIND_QUIETLY)
      message(STATUS "Fortran_${_id}_RUNTIME_LIBRARIES=${Fortran_${_id}_RUNTIME_LIBRARIES}")
      message(STATUS "Fortran_${_id}_RUNTIME_DIRECTORIES=${Fortran_${_id}_RUNTIME_DIRECTORIES}")
    endif()
  endif()
endfunction()

function(_fortran_find_compiler_executable)
  # Caller must defined these variables
   _fortran_assert(DEFINED _id)

  # Vendor-specific compiler names (copied from CMakeDetermineFortranCompiler.cmake)
  set(_Fortran_COMPILER_NAMES_GNU       gfortran gfortran-4 g95 g77)
  set(_Fortran_COMPILER_NAMES_Intel     ifort ifc efc)
  set(_Fortran_COMPILER_NAMES_Absoft    af95 af90 af77)
  set(_Fortran_COMPILER_NAMES_PGI       pgf95 pgfortran pgf90 pgf77)
  set(_Fortran_COMPILER_NAMES_Flang     flang)
  set(_Fortran_COMPILER_NAMES_PathScale pathf2003 pathf95 pathf90)
  set(_Fortran_COMPILER_NAMES_XL        xlf)
  set(_Fortran_COMPILER_NAMES_VisualAge xlf95 xlf90 xlf)
  set(_Fortran_COMPILER_NAMES_NAG       nagfor)

  set(_Fortran_COMPILER_NAMES_G95       g95)
  set(_Fortran_COMPILER_NAMES_Cray      ftn)
  set(_Fortran_COMPILER_NAMES_SunPro    f90 f77)

  list(APPEND _Fortran_COMPILER_NAMES_GNU f95)

  # Adapted from _cmake_find_compiler() available in CMakeDetermineCompiler.cmake

  # Use already-enabled languages for reference.
  get_property(_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  list(REMOVE_ITEM _languages "Fortran")

  # Compiler list
  set(_Fortran_COMPILER_LIST ${_Fortran_COMPILER_NAMES_${_id}})

  # Look for directories containing compilers.
  set(_Fortran_COMPILER_HINTS)
  foreach(l IN ITEMS ${_languages} Fortran)
    if(CMAKE_${l}_COMPILER AND IS_ABSOLUTE "${CMAKE_${l}_COMPILER}")
      get_filename_component(_hint "${CMAKE_${l}_COMPILER}" PATH)
      if(IS_DIRECTORY "${_hint}")
        list(APPEND _Fortran_COMPILER_HINTS "${_hint}")
      endif()
      unset(_hint)
    endif()
  endforeach()

  # Find the compiler.
  if(_Fortran_COMPILER_HINTS)
    # Prefer directories containing compilers of reference languages.
    list(REMOVE_DUPLICATES _Fortran_COMPILER_HINTS)
    find_program(Fortran_${_id}_EXECUTABLE
      NAMES ${_Fortran_COMPILER_LIST}
      PATHS ${_Fortran_COMPILER_HINTS}
      NO_DEFAULT_PATH
      DOC "${_id} Fortran compiler")
  endif()

  find_program(Fortran_${_id}_EXECUTABLE NAMES ${_Fortran_COMPILER_LIST} DOC "${_id} Fortran compiler")
endfunction()

function(_fortran_set_unix_runtime_cache_variables)
  # Caller must defined these variables
   _fortran_assert(DEFINED _id)
   _fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
   _fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)

  set(_link_libs ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
  # These libraries are expected to be available.
  # See https://www.python.org/dev/peps/pep-0513/#the-manylinux1-policy
  list(REMOVE_ITEM _link_libs c crypt dl gcc_s m nsl rt util pthread stdc++)
  set(_runtime_lib_dirs ${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES})
  set(_runtime_lib_suffix ".so")
  _fortran_set_runtime_cache_variables()
endfunction()

# First, prefer Fortran vendor
if(NOT DEFINED Fortran_COMPILER_ID)
  if(CMAKE_Fortran_COMPILER_ID)
    set(Fortran_COMPILER_ID ${CMAKE_Fortran_COMPILER_ID})
  endif()
endif()

# Then, prefer already-enabled languages
if(NOT DEFINED Fortran_COMPILER_ID)
  get_property(_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  list(REMOVE_ITEM _languages "Fortran")
  if(_languages)
    list(GET _languages 0 _first_lang)
    set(Fortran_COMPILER_ID ${CMAKE_${_first_lang}_COMPILER_ID})
  endif()
  unset(_languages)
endif()

if(NOT DEFINED Fortran_COMPILER_ID)
  if(Fortran_FIND_REQUIRED)
    message(FATAL_ERROR "Fortran_COMPILER_ID variable must be set")
  else()
    if(NOT Fortran_FIND_QUIETLY)
      # TODO Display message
    endif()
    return()
  endif()
endif()

set(_additional_required_vars)

# convenient shorter variable name
set(_id ${Fortran_COMPILER_ID})

# compiler executable
_fortran_find_compiler_executable()

if(_id STREQUAL "Flang" AND CMAKE_HOST_WIN32)
  # Set companion compiler variables
  get_filename_component(_flang_bin_dir ${Fortran_${_id}_EXECUTABLE} DIRECTORY)
  find_program(Fortran_${_id}_CLANG_CL_EXECUTABLE clang-cl.exe HINTS ${_flang_bin_dir})
  list(APPEND _additional_required_vars Fortran_${_id}_CLANG_CL_EXECUTABLE)

  # Set implicit linking variables
  if(NOT DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
    set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES flangmain flang flangrti ompstub)
    set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES ${_flang_bin_dir}/../lib)
    set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES )
    _fortran_set_implicit_linking_cache_variables()
  endif()

  # Set runtime variables
  set(_link_libs ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
  set(_runtime_lib_dirs ${_flang_bin_dir})
  set(_runtime_lib_suffix ".dll")
  _fortran_set_runtime_cache_variables()

  unset(_flang_bin_dir)

elseif(_id MATCHES "^Flang|GNU|G95|Intel|SunPro|Cray|G95|PathScale|Absoft|XL|VisualAge|PGI|NAG$")

  # Set implicit linking variables
  if(NOT DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
    _fortran_retrieve_implicit_link_info()
    _fortran_set_implicit_linking_cache_variables()
  endif()

  # Set runtime variables
  _fortran_set_unix_runtime_cache_variables()

elseif(_id MATCHES "^zOS|HP$")
  message(FATAL_ERROR "Setting Fortran_COMPILER_ID to '${_id}' is not yet supported")

else()
  message(FATAL_ERROR "Setting Fortran_COMPILER_ID to '${_id}' is invalid")
endif()

# all variables must be defined
_fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
_fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)
_fortran_assert(DEFINED Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
_fortran_assert(DEFINED Fortran_${_id}_RUNTIME_LIBRARIES)
_fortran_assert(DEFINED Fortran_${_id}_RUNTIME_DIRECTORIES)

# directory variable is required if corresponding library variable is non-empty
if(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
  list(APPEND _additional_required_vars Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)
endif()
if(Fortran_${_id}_RUNTIME_LIBRARIES)
  list(APPEND _additional_required_vars Fortran_${_id}_RUNTIME_DIRECTORIES)
endif()

# outputs
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Fortran
  REQUIRED_VARS
    Fortran_${_id}_EXECUTABLE
    ${_additional_required_vars}
  )

# conveniently set CMake implicit linking variables it not already defined
if(NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES
    AND NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES
    AND NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
  set(CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
  set(CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES ${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES})
  set(CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES ${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES})
endif()

# clean
unset(_additional_required_vars)
unset(_find_compiler_hints)
unset(_id)
