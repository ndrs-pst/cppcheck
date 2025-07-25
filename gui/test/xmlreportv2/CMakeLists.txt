qt_wrap_cpp(test-xmlreportv2_SRC testxmlreportv2.h)
add_custom_target(build-xmlreportv2-deps SOURCES ${test-xmlreportv2_SRC})
add_dependencies(gui-build-deps build-xmlreportv2-deps)
if (NOT BUILD_CORE_DLL)
    list(APPEND test-xmlreportv2_SRC $<TARGET_OBJECTS:cppcheck-core> $<TARGET_OBJECTS:simplecpp_objs>)
    if(USE_BUNDLED_TINYXML2)
        list(APPEND test-xmlreportv2_SRC $<TARGET_OBJECTS:tinyxml2_objs>)
    endif()
endif()
add_executable(test-xmlreportv2
        ${test-xmlreportv2_SRC}
        testxmlreportv2.cpp
        ${CMAKE_SOURCE_DIR}/gui/erroritem.cpp
        ${CMAKE_SOURCE_DIR}/gui/report.cpp
        ${CMAKE_SOURCE_DIR}/gui/xmlreport.cpp
        ${CMAKE_SOURCE_DIR}/gui/xmlreportv2.cpp
        )
target_include_directories(test-xmlreportv2 PRIVATE ${CMAKE_SOURCE_DIR}/gui ${CMAKE_SOURCE_DIR}/lib)
target_compile_definitions(test-xmlreportv2 PRIVATE SRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(test-xmlreportv2 ${QT_CORE_LIB} ${QT_TEST_LIB})
if (HAVE_RULES)
    target_link_libraries(test-xmlreportv2 ${PCRE_LIBRARY})
endif()
if(tinyxml2_FOUND AND NOT USE_BUNDLED_TINYXML2)
    target_link_libraries(test-xmlreportv2 ${tinyxml2_LIBRARIES})
endif()
if (BUILD_CORE_DLL)
    target_compile_definitions(test-xmlreportv2 PRIVATE CPPCHECKLIB_IMPORT TINYXML2_IMPORT)
    target_link_libraries(test-xmlreportv2 cppcheck-core)
endif()
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if(QT_VERSION VERSION_LESS "6.0.0")
        # Q_UNUSED() in generated code - see https://bugreports.qt.io/browse/QTBUG-82978
        target_compile_options_safe(test-xmlreportv2 -Wno-extra-semi-stmt)
    endif()
    if(QT_VERSION VERSION_GREATER_EQUAL "6.9.0")
        # caused by Qt generated moc code starting with 6.9.0 - see https://bugreports.qt.io/browse/QTBUG-135638
        target_compile_options_safe(test-xmlreportv2 -Wno-ctad-maybe-unsupported)
    endif()
endif()

if (REGISTER_GUI_TESTS)
    add_test(NAME test-xmlreportv2 COMMAND $<TARGET_FILE:test-xmlreportv2>)
endif()

add_dependencies(gui-tests test-xmlreportv2)
