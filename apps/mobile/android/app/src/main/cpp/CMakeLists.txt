cmake_minimum_required(VERSION 3.10)
project(native_showcase)

add_library(
  native_showcase
  SHARED
  ../../../../../../../native/native_showcase/native_showcase.c
)

target_include_directories(
  native_showcase
  PRIVATE
  ../../../../../../../native/native_showcase
)
