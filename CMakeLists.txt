cmake_minimum_required(VERSION 3.16)

project(MyFirstQT VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS 
    Core
    Gui
    Widgets
    Quick
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(qtapp
    main.cpp
    MainWindow.cpp
    HexItem.cpp
    HexBoardScene.cpp
)

# This resolves all the warnings qmllint gives
set(QT_QML_GENERATE_QMLLS_INI ON)

qt_add_qml_module(qtapp
    URI qtapp
    VERSION 1.0
    QML_FILES
        Main.qml
    RESOURCES Bluebubble.svg
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/qtapp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(qtapp PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMyFirstQT
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(qtapp PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS qtapp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)