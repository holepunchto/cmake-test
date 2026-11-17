include_guard()

set(TEST_TIMEOUT 30 CACHE STRING "Seconds before each test times out")

function(add_test_executable target)
  set(one_value_keywords
    TIMEOUT
    WORKING_DIRECTORY
  )

  set(multi_value_keywords
    LINK
    ARGS
    LABELS
    PROPERTIES
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  if(NOT ARGV_TIMEOUT)
    set(ARGV_TIMEOUT ${TEST_TIMEOUT})
  endif()

  if(NOT ARGV_LABELS)
    set(ARGV_LABELS unit)
  endif()

  if(NOT ARGV_WORKING_DIRECTORY)
    set(ARGV_WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
  endif()

  add_executable(${target} ${ARGV_UNPARSED_ARGUMENTS})

  # Tests check their results with assert(), which NDEBUG would compile out.
  if(MSVC)
    target_compile_options(${target} PRIVATE /UNDEBUG)
  else()
    target_compile_options(${target} PRIVATE -UNDEBUG)
  endif()

  target_link_libraries(
    ${target}
    PRIVATE
      ${ARGV_LINK}
  )

  if(WIN32)
    get_directory_property(executables test_runtime_dll_executables)

    if(NOT executables)
      cmake_language(DEFER CALL copy_test_runtime_dlls)
    endif()

    set_property(DIRECTORY APPEND PROPERTY test_runtime_dll_executables ${target})
  endif()

  add_test(
    NAME ${target}
    COMMAND ${target} ${ARGV_ARGS}
    WORKING_DIRECTORY "${ARGV_WORKING_DIRECTORY}"
  )

  set_tests_properties(
    ${target}
    PROPERTIES
      TIMEOUT ${ARGV_TIMEOUT}
      LABELS "${ARGV_LABELS}"
      ${ARGV_PROPERTIES}
  )
endfunction()

# Windows searches the system directories before PATH, so a DLL that shares its
# name with a system DLL must sit next to the executable to be found. The DLLs
# are copied once per directory, as concurrent copies of the same DLL from each
# test fail with a sharing violation.
function(copy_test_runtime_dlls)
  get_directory_property(executables test_runtime_dll_executables)

  set(dlls)

  foreach(executable IN LISTS executables)
    list(APPEND dlls "$<TARGET_RUNTIME_DLLS:${executable}>")
  endforeach()

  set(dlls "$<REMOVE_DUPLICATES:$<FILTER:${dlls},EXCLUDE,^$>>")

  list(GET executables 0 executable)

  cmake_path(RELATIVE_PATH CMAKE_CURRENT_BINARY_DIR BASE_DIRECTORY "${CMAKE_BINARY_DIR}" OUTPUT_VARIABLE target)

  string(MAKE_C_IDENTIFIER "test_runtime_dlls_${target}" target)

  add_custom_target(
    ${target}
    ALL
    COMMAND "$<IF:$<BOOL:${dlls}>,${CMAKE_COMMAND};-E;copy_if_different;${dlls};$<TARGET_FILE_DIR:${executable}>,${CMAKE_COMMAND};-E;true>"
    COMMAND_EXPAND_LISTS
    VERBATIM
  )

  add_dependencies(${target} ${executables})
endfunction()

function(add_test_executables)
  set(one_value_keywords
    PREFIX
    BASE_DIRECTORY
    TIMEOUT
    WORKING_DIRECTORY
  )

  set(multi_value_keywords
    DISABLED
    LINK
    ARGS
    LABELS
    PROPERTIES
  )

  cmake_parse_arguments(
    PARSE_ARGV 0 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  _resolve_test_files(sources disabled)

  set(forwarded_arguments)

  foreach(keyword IN LISTS one_value_keywords multi_value_keywords)
    if(keyword MATCHES "^(PREFIX|BASE_DIRECTORY|DISABLED|PROPERTIES)$" OR NOT DEFINED ARGV_${keyword})
      continue()
    endif()

    list(APPEND forwarded_arguments ${keyword} ${ARGV_${keyword}})
  endforeach()

  foreach(source IN LISTS sources)
    cmake_path(RELATIVE_PATH source BASE_DIRECTORY "${ARGV_BASE_DIRECTORY}" OUTPUT_VARIABLE target)

    cmake_path(REMOVE_EXTENSION target LAST_ONLY)

    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target "${ARGV_PREFIX}${target}")

    set(properties ${ARGV_PROPERTIES})

    if(source IN_LIST disabled)
      list(APPEND properties DISABLED ON)
    endif()

    add_test_executable(${target} "${source}" ${forwarded_arguments} PROPERTIES ${properties})
  endforeach()
endfunction()

function(add_test_script name file)
  set(one_value_keywords
    TIMEOUT
    WORKING_DIRECTORY
  )

  set(multi_value_keywords
    RUNNER
    ARGS
    LABELS
    PROPERTIES
  )

  cmake_parse_arguments(
    PARSE_ARGV 2 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  if(NOT ARGV_RUNNER)
    message(FATAL_ERROR "RUNNER is required")
  endif()

  if(NOT ARGV_TIMEOUT)
    set(ARGV_TIMEOUT ${TEST_TIMEOUT})
  endif()

  if(NOT ARGV_LABELS)
    set(ARGV_LABELS unit)
  endif()

  if(NOT ARGV_WORKING_DIRECTORY)
    set(ARGV_WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
  endif()

  cmake_path(ABSOLUTE_PATH file NORMALIZE)

  add_test(
    NAME ${name}
    COMMAND ${ARGV_RUNNER} "${file}" ${ARGV_ARGS}
    WORKING_DIRECTORY "${ARGV_WORKING_DIRECTORY}"
  )

  set_tests_properties(
    ${name}
    PROPERTIES
      TIMEOUT ${ARGV_TIMEOUT}
      LABELS "${ARGV_LABELS}"
      ${ARGV_PROPERTIES}
  )
endfunction()

function(add_test_scripts)
  set(one_value_keywords
    PREFIX
    BASE_DIRECTORY
    TIMEOUT
    WORKING_DIRECTORY
  )

  set(multi_value_keywords
    DISABLED
    RUNNER
    ARGS
    LABELS
    PROPERTIES
  )

  cmake_parse_arguments(
    PARSE_ARGV 0 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  _resolve_test_files(files disabled)

  set(forwarded_arguments)

  foreach(keyword IN LISTS one_value_keywords multi_value_keywords)
    if(keyword MATCHES "^(PREFIX|BASE_DIRECTORY|DISABLED|PROPERTIES)$" OR NOT DEFINED ARGV_${keyword})
      continue()
    endif()

    list(APPEND forwarded_arguments ${keyword} ${ARGV_${keyword}})
  endforeach()

  foreach(file IN LISTS files)
    cmake_path(RELATIVE_PATH file BASE_DIRECTORY "${ARGV_BASE_DIRECTORY}" OUTPUT_VARIABLE name)

    set(properties ${ARGV_PROPERTIES})

    if(file IN_LIST disabled)
      list(APPEND properties DISABLED ON)
    endif()

    add_test_script("${ARGV_PREFIX}${name}" "${file}" ${forwarded_arguments} PROPERTIES ${properties})
  endforeach()
endfunction()

# Resolves the unparsed test files and the DISABLED files of the calling
# function against its BASE_DIRECTORY, and checks that every disabled file is
# one of the tests.
macro(_resolve_test_files files_result disabled_result)
  if(NOT ARGV_BASE_DIRECTORY)
    set(ARGV_BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()

  cmake_path(ABSOLUTE_PATH ARGV_BASE_DIRECTORY NORMALIZE)

  set(${files_result})
  set(${disabled_result})

  foreach(_file IN LISTS ARGV_UNPARSED_ARGUMENTS)
    cmake_path(ABSOLUTE_PATH _file BASE_DIRECTORY "${ARGV_BASE_DIRECTORY}" NORMALIZE)

    list(APPEND ${files_result} "${_file}")
  endforeach()

  foreach(_file IN LISTS ARGV_DISABLED)
    cmake_path(ABSOLUTE_PATH _file BASE_DIRECTORY "${ARGV_BASE_DIRECTORY}" NORMALIZE)

    if(NOT _file IN_LIST ${files_result})
      message(FATAL_ERROR "${_file} is disabled, but isn't a test")
    endif()

    list(APPEND ${disabled_result} "${_file}")
  endforeach()
endmacro()

# A macro, as enable_testing() records its state in a variable of the calling
# scope that a function would discard.
macro(add_test_subdirectory)
  if(PROJECT_IS_TOP_LEVEL)
    enable_testing()

    add_subdirectory(${ARGV})
  endif()
endmacro()
