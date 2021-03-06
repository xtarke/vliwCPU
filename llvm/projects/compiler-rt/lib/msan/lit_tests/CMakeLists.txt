set(MSAN_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)
set(MSAN_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/..)

configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
  )

configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/Unit/lit.site.cfg.in
  ${CMAKE_CURRENT_BINARY_DIR}/Unit/lit.site.cfg
  )

if(COMPILER_RT_CAN_EXECUTE_TESTS)
  # Run MSan tests only if we're sure we may produce working binaries.
  set(MSAN_TEST_DEPS
    clang clang-headers FileCheck count not llvm-nm llvm-symbolizer
    ${MSAN_RUNTIME_LIBRARIES}
    )
  set(MSAN_TEST_PARAMS
    msan_site_config=${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
    )
  if(LLVM_INCLUDE_TESTS)
    list(APPEND MSAN_TEST_DEPS MsanUnitTests)
  endif()
  add_lit_testsuite(check-msan "Running the MemorySanitizer tests"
    ${CMAKE_CURRENT_BINARY_DIR}
    PARAMS ${MSAN_TEST_PARAMS}
    DEPENDS ${MSAN_TEST_DEPS}
    )
  set_target_properties(check-msan PROPERTIES FOLDER "MSan tests")
endif()
