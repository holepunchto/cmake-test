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

  # Windows searches the system directories before PATH, so a DLL that shares
  # its name with a system DLL must sit next to the executable to be found.
  if(WIN32)
    add_custom_command(
      TARGET ${target}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy -t $<TARGET_FILE_DIR:${target}> $<TARGET_RUNTIME_DLLS:${target}>
      COMMAND_EXPAND_LISTS
    )
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

function(add_test_executables)
  set(one_value_keywords
    PREFIX
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
    PARSE_ARGV 0 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  set(forwarded_arguments)

  foreach(keyword IN LISTS one_value_keywords multi_value_keywords)
    if(keyword STREQUAL "PREFIX" OR NOT DEFINED ARGV_${keyword})
      continue()
    endif()

    list(APPEND forwarded_arguments ${keyword} ${ARGV_${keyword}})
  endforeach()

  foreach(source IN LISTS ARGV_UNPARSED_ARGUMENTS)
    cmake_path(ABSOLUTE_PATH source NORMALIZE OUTPUT_VARIABLE target)
    cmake_path(RELATIVE_PATH target BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    cmake_path(REMOVE_EXTENSION target LAST_ONLY)

    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target "${ARGV_PREFIX}${target}")

    add_test_executable(${target} ${source} ${forwarded_arguments})
  endforeach()
endfunction()

# A macro, as enable_testing() records its state in a variable of the calling
# scope that a function would discard.
macro(add_test_subdirectory)
  if(PROJECT_IS_TOP_LEVEL)
    enable_testing()

    add_subdirectory(${ARGV})
  endif()
endmacro()
