add_custom_target(LLDBUnitTests)
set_target_properties(LLDBUnitTests PROPERTIES FOLDER "LLDB/Tests")

add_dependencies(lldb-unit-test-deps LLDBUnitTests)

include_directories(${LLDB_SOURCE_ROOT})
include_directories(${LLDB_PROJECT_ROOT}/unittests)

if (CXX_SUPPORTS_SUGGEST_OVERRIDE_FLAG)
  add_compile_options("-Wno-suggest-override")
endif()

function(add_lldb_unittest test_name)
  cmake_parse_arguments(ARG
    ""
    ""
    "LINK_LIBS;LINK_COMPONENTS"
    ${ARGN})

  if (NOT ${test_name} MATCHES "Tests$")
    message(FATAL_ERROR "Unit test name must end with 'Tests' for lit to find it.")
  endif()

  list(APPEND LLVM_LINK_COMPONENTS ${ARG_LINK_COMPONENTS})

  add_unittest(LLDBUnitTests
    ${test_name}
    ${ARG_UNPARSED_ARGUMENTS}
    )

  add_custom_command(
    TARGET ${test_name}
    POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Inputs)

  target_link_libraries(${test_name} PRIVATE ${ARG_LINK_LIBS})
endfunction()

function(add_unittest_inputs test_name inputs)
  foreach (INPUT ${inputs})
    add_custom_command(
      TARGET ${test_name}
      POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Inputs/${INPUT} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Inputs
      COMMENT "Copying ${INPUT} to binary directory.")
  endforeach()
endfunction()

add_subdirectory(TestingSupport)
if (NOT CMAKE_SYSTEM_NAME MATCHES "Windows")
  # FIXME: Tests linking against libLLDB don't work on Windows.
  add_subdirectory(API)
  add_subdirectory(DAP)
endif()
add_subdirectory(ABI)
add_subdirectory(Breakpoint)
add_subdirectory(Callback)
add_subdirectory(Core)
add_subdirectory(DataFormatter)
add_subdirectory(Disassembler)
add_subdirectory(Editline)
add_subdirectory(Expression)
add_subdirectory(Host)
add_subdirectory(Interpreter)
add_subdirectory(Instruction)
add_subdirectory(Language)
add_subdirectory(ObjectFile)
add_subdirectory(Platform)
add_subdirectory(Process)
add_subdirectory(ScriptInterpreter)
add_subdirectory(Signals)
add_subdirectory(Symbol)
add_subdirectory(SymbolFile)
add_subdirectory(Target)
add_subdirectory(tools)
add_subdirectory(UnwindAssembly)
add_subdirectory(Utility)
add_subdirectory(Thread)
add_subdirectory(ValueObject)

if(LLDB_CAN_USE_DEBUGSERVER AND LLDB_TOOL_DEBUGSERVER_BUILD AND NOT LLDB_USE_SYSTEM_DEBUGSERVER)
  add_subdirectory(debugserver)
endif()
