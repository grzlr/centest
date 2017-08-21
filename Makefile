#all: centest librs_demo vis_pfm rsm_error

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
machine := $(shell sh -c "$(CC) -dumpmachine || echo unknown")


ifeq ($(uname_S),Darwin)
CXXFLAGS += -I/usr/local/include
GLFW3_FLAGS := -lglfw -framework OpenGL
else
GLFW3_FLAGS := `pkg-config --cflags --libs glfw3 gl`
endif

CXX ?= g++
# Extension of source files used in the project
SRC_EXT = cpp
# Path to the source directory, relative to the makefile
LIBS =  
# General compiler flags
COMPILE_FLAGS = -std=c++14  
#COMPILE_FLAGS = -std=c++11 -g -w  
# Additional release-specific flags
RCOMPILE_FLAGS = -D NDEBUG -march=native -Ofast #-fopenmp 
# Additional debug-specific flags
DCOMPILE_FLAGS = -D DEBUG -g -Wall -Wunused-variable
# Add additional include paths
INCLUDES = -I src/
# General linker settings
LINK_FLAGS = $(GLFW3_FLAGS) 
# Additional release-specific linker settings
RLINK_FLAGS = 
# Additional debug-specific linker settings
DLINK_FLAGS = 
# Destination directory, like a jail or mounted system
DESTDIR = /
# Install path (bin/ is appended automatically)
INSTALL_PREFIX = usr/local
#### END PROJECT SETTINGS ####

# Generally should not need to edit below this line

# Shell used in this makefile
# bash is used for 'echo -en'
SHELL = /bin/bash
# Clear built-in rules
.SUFFIXES:

# Append pkg-config specific libraries if need be
ifneq ($(LIBS),)
	COMPILE_FLAGS += $(shell pkg-config --cflags $(LIBS))
	LINK_FLAGS += $(shell pkg-config --libs $(LIBS))
endif

# Combine compiler and linker flags
DEBUG ?= 0
ifeq ($(DEBUG), 1)
	export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
else
	export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
endif

SRC = $(wildcard src/*.cpp)
OBJ = $(patsubst src/%.cpp, src/%.o, $(SRC))

ALG_SRC = $(wildcard src/*Match.cpp)
ALG_OBJ = $(patsubst src/%.cpp, obj/%.o, $(ALG_SRC))
#src/%.o: src/%.cpp
#	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<
all: vis_pfm rms_error librs_demo centest cost_to_conf subpixel_extract
obj:
	mkdir -p obj/
obj/%.o: src/%.cpp | obj
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
rms_error: obj/rms_error.o obj/imio.o
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@
vis_pfm: obj/vis_pfm.o obj/imio.o
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@
librs_demo: obj/rs_demo.o obj/imio.o obj/imshow.o $(ALG_OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -Iinclude $(GLFW3_FLAGS) -lrealsense -o $@
centest: obj/Main.o obj/imio.o obj/imshow.o $(ALG_OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -Iinclude $(GLFW3_FLAGS) -o $@
cost_to_conf: obj/cost_to_conf.o obj/imio.o obj/imshow.o $(ALG_OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -Iinclude $(GLFW3_FLAGS) -o $@
subpixel_extract: obj/subpixel_extract.o obj/imio.o obj/imshow.o $(ALG_OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -Iinclude $(GLFW3_FLAGS) -o $@
clean:
	rm -f vis_pfm rms_error librs_demo centest cost_to_conf subpixel_extract
	rm -rf obj/
