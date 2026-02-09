cmake_minimum_required(VERSION 3.16)

project(appstamps LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

qt_add_executable(appstamps
    main.cpp
    database.cpp
    database.h
    qml.qrc
    stamps.h stamps.cpp
    collections.h collections.cpp
    reports.h reports.cpp
)

target_link_libraries(appstamps
    PRIVATE Qt6::Quick Qt6::Sql
)
