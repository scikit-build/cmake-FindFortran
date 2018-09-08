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


function(_fortran_retrieve_implicit_link_info _id _fortran_compiler _additional_cmake_options)
  if(NOT DEFINED Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)
    set(_desc "Retrieving ${_id} Fortran compiler implicit link info")
    message(STATUS ${_desc})
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
      COMMAND ${CMAKE_COMMAND} . -DCMAKE_Fortran_COMPILER:FILEPATH=${_fortran_compiler}
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
    else()
      set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES NOTFOUND)
      set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES NOTFOUND)
      set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES NOTFOUND)
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "${_desc} failed with the following output:\n"
        "${output}\n")
    endif()
    message(STATUS "${_desc} - done")
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_LIBRARIES=${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES}")
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES=${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES}")
    message(STATUS "Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES=${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}")

    set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES "${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES}" CACHE STRING "${lang} Fortran compiler implicit link libraries")
    mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES)

    set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES}" CACHE STRING "${lang} Fortran compiler implicit link directories")
    mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES)

    set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}" CACHE STRING "${lang} Fortran compiler implicit link framework directories")
    mark_as_advanced(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
  endif()
endfunction()

function(_find_runtime_libs_and_set_variables)
  if(NOT DEFINED Fortran_${_id}_RUNTIME_LIBS)
    set(CMAKE_FIND_LIBRARY_SUFFIXES "${_runtime_lib_suffix}")

    set(runtime_libs)
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
      list(APPEND runtime_libs ${Fortran_${_id}_${_lib}_RUNTIME_LIBRARY})

      get_filename_component(_runtime_dir ${Fortran_${_id}_${_lib}_RUNTIME_LIBRARY} DIRECTORY)
      list(APPEND _runtime_dirs ${_runtime_dir})
    endforeach()
    list(REMOVE_DUPLICATES _runtime_dirs)

    set(Fortran_${_id}_RUNTIME_LIBS ${runtime_libs} CACHE FILEPATH "${_id} Fortran compiler runtime libraries")
    mark_as_advanced(Fortran_${_id}_RUNTIME_LIBS)

    set(Fortran_${_id}_RUNTIME_DIRECTORIES ${_runtime_dirs} CACHE FILEPATH "${_id} Fortran compiler runtime directories")
    mark_as_advanced(Fortran_${_id}_RUNTIME_DIRECTORIES)

    message(STATUS "Fortran_${_id}_RUNTIME_LIBS=${Fortran_${_id}_RUNTIME_LIBS}")
    message(STATUS "Fortran_${_id}_RUNTIME_DIRECTORIES=${Fortran_${_id}_RUNTIME_DIRECTORIES}")
  endif()
endfunction()

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
    get_filename_component(_flang_bin_dir ${Fortran_${_id}_EXECUTABLE} DIRECTORY)
    find_program(Fortran_${_id}_CLANG_CL_EXECUTABLE clang-cl.exe HINTS ${_flang_bin_dir})
    list(APPEND _required_vars Fortran_${_id}_CLANG_CL_EXECUTABLE)


    # Set *_IMPLICIT_LINK_* variables
    set(Fortran_${_id}_IMPLICIT_LINK_LIBRARIES flangmain flang flangrti ompstub)
    set(Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES ${_flang_bin_dir}/../lib)
    set(Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES )

    # Set *_RUNTIME_LIBS and *_RUNTIME_LIBRARY variables
    set(_link_libs ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
    set(_runtime_lib_dirs ${_flang_bin_dir})
    set(_runtime_lib_suffix ".dll")
    _find_runtime_libs_and_set_variables()

    unset(_flang_bin_dir)
  endif()

elseif(_id STREQUAL "GNU")
  find_program(Fortran_${_id}_EXECUTABLE gfortran ${_find_compiler_hints})

  # Set *_IMPLICIT_LINK_* variables
  _fortran_retrieve_implicit_link_info(${_id} ${Fortran_${_id}_EXECUTABLE} "")

  # Set *_RUNTIME_LIBS and *_RUNTIME_LIBRARY variables
  set(_link_libs ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
  list(REMOVE_DUPLICATES _link_libs)
  list(REMOVE_ITEM _link_libs "c" "m")
  set(_runtime_lib_dirs ${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES})
  set(_runtime_lib_suffix ".so")
  _find_runtime_libs_and_set_variables()

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

# conveniently set CMAKE_Fortran_IMPLICIT_LINK_* variables it not already defined
if(NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES
    AND NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES
    AND NOT DEFINED CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
  set(CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES ${Fortran_${_id}_IMPLICIT_LINK_LIBRARIES})
  set(CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES ${Fortran_${_id}_IMPLICIT_LINK_DIRECTORIES})
  set(CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES ${Fortran_${_id}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES})
endif()

# clean
unset(_find_compiler_hints)
unset(_id)
unset(_required_vars)
