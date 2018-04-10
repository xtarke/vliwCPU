cmake_minimum_required(VERSION 2.6)
project(soft_sim)

add_executable(soft_sim ./src/main.cpp ./src/Interlock.cpp ./src/Cache.cpp ./src/logger.cpp ./src/HexRead.cpp ./src/MifRead.cpp ./src/Rom.cpp ./src/SPram.cpp ./src/Control.cpp ./src/CPU.cpp src/Decoder.cpp ./src/Execute.cpp ./src/Fetch.cpp ./src/ImmSolve.cpp ./src/InstructDecode.cpp ./src/Slot.cpp ./src/MemOperation.cpp  ./src/Memory.cpp  ./src/Regist.cpp ./src/ULA.cpp)

install(TARGETS soft_sim RUNTIME DESTINATION bin)


SET(CMAKE_CXX_FLAGS "-std=c++0x")