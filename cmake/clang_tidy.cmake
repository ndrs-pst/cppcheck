# TODO: bail out when Python_EXECUTABLE is not set

if(NOT CMAKE_DISABLE_PRECOMPILE_HEADERS)
    # clang-tidy and clang need to have the same version when precompiled headers are being used
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        string(REGEX MATCHALL "[0-9]+" _clang_ver_parts "${CMAKE_CXX_COMPILER_VERSION}")
        LIST(GET _clang_ver_parts 0 _clang_major)
        set(RUN_CLANG_TIDY_NAMES "run-clang-tidy-${_clang_major}")
        message(STATUS "Clang and clang-tidy version need to match when precompiled headers are enabled - limiting search to '${RUN_CLANG_TIDY_NAMES}'")
    else()
        message(STATUS "Cannot use non-Clang compiler with clang-tidy when precompiled headers are enabled - skipping 'run-clang-tidy' target generation")
    endif()
else()
    set(RUN_CLANG_TIDY_NAMES run-clang-tidy run-clang-tidy-20 run-clang-tidy-19 run-clang-tidy-18 run-clang-tidy-17 run-clang-tidy-16 run-clang-tidy-15 run-clang-tidy-14 run-clang-tidy-13 run-clang-tidy-12 run-clang-tidy-11 run-clang-tidy-10 run-clang-tidy-9 run-clang-tidy-8)
endif()

if(RUN_CLANG_TIDY_NAMES)
    find_program(RUN_CLANG_TIDY NAMES ${RUN_CLANG_TIDY_NAMES})
    message(STATUS "RUN_CLANG_TIDY=${RUN_CLANG_TIDY}")
    if(RUN_CLANG_TIDY)
        include(ProcessorCount)
        ProcessorCount(NPROC)
        if(NPROC EQUAL 0)
            message(FATAL_ERROR "could not get processor count")
        endif()
        message(STATUS "NPROC=${NPROC}")

        # TODO: exclude moc_*.cpp
        # TODO: exclude mocs_compilation.cpp
        # disable all compiler warnings since we are just interested in the tidy ones
        add_custom_target(run-clang-tidy
                ${Python_EXECUTABLE} ${RUN_CLANG_TIDY} -p=${CMAKE_BINARY_DIR} -j ${NPROC} -quiet
                USES_TERMINAL)
        if(BUILD_GUI)
            add_dependencies(run-clang-tidy gui-build-deps)
            if(BUILD_TRIAGE)
                add_dependencies(run-clang-tidy triage-build-ui-deps)
            endif()
        endif()
    endif()
endif()
