cmake_minimum_required(VERSION 3.16)

project(QtApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

# This resolves all the warnings qmllint gives
#set(QT_QML_GENERATE_QMLLS_INI ON)

qt_standard_project_setup(REQUIRES 6.8)

# Define the source files for your executable
set(APP_SOURCES
    main.cpp
)

qt_add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${APP_SOURCES})

qt_add_qml_module(${PROJECT_NAME}
    URI QtAppQml
    VERSION 1.0
    QML_FILES
        Main.qml
        Hexagon.qml
        # UnitItem.qml 
    RESOURCES 
        Bluebubble.svg
    SOURCES
        BoardModel.h # Include header for MOC processing        
        BoardModel.cpp
        HexCoordConverter.h # Include header for MOC processing  
        HexCoordConverter.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTest
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)