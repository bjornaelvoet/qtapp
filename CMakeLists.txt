cmake_minimum_required(VERSION 3.16)

project(QtApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS 
    Core
    Gui
    Widgets
    Qml
    Quick
)

qt_standard_project_setup(REQUIRES 6.8)

# This resolves all the warnings qmllint gives
set(QT_QML_GENERATE_QMLLS_INI ON)

qt_add_qml_module(QtAppQmlModule
    URI QtAppQml
    VERSION 1.0
    QML_FILES
        Main.qml
        Hexagon.qml
        # UnitItem.qml 
    RESOURCES 
        Bluebubble.svg
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/QtAppQml
)

# Define the source files for your executable
set(APP_SOURCES
    Main.cpp
    BoardModel.cpp
    HexCoordConverter.cpp
)

# Define the MOC-able headers. These will be processed by MOC.
set(APP_MOC_HEADERS
    BoardModel.h
    HexCoordConverter.h
)

qt_add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${APP_SOURCES})

set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTest
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    QtAppQmlModule
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)