cmake_minimum_required(VERSION 3.25)
project(UARTdebug_for_win)

set(CMAKE_CXX_STANDARD 17)

add_executable(UARTdebug_for_win main.cpp COMM_test.h)
