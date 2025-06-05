# Makefile for cross-platform Tree-sitter parser compilation

# Detect operating system
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    OS := linux
    EXT := so
    CC := gcc
    CXX := g++
    CFLAGS := -c -fPIC -I./src -O2
    LDFLAGS := -shared
endif
ifeq ($(UNAME_S),Darwin)
    OS := macos
    EXT := dylib
    CC := clang
    CXX := clang++
    CFLAGS := -c -fPIC -I./src -O2
    LDFLAGS := -dynamiclib -Wl,-install_name,libtree-sitter-rholang.$(EXT)
endif
ifeq ($(OS),Windows_NT)
    OS := windows
    EXT := dll
    CC := cl.exe
    CXX := cl.exe
    CFLAGS := /c /I.\src /O2
    LDFLAGS := /DLL /OUT:libtree-sitter-rholang.$(EXT)
endif

# Output library name
LIBNAME := libtree-sitter-rholang.$(EXT)

# Source files
SRC_DIR := src
SOURCES := $(SRC_DIR)/parser.c
SCANNER_C := $(SRC_DIR)/scanner.c
SCANNER_CPP := $(SRC_DIR)/scanner.cc

# Check for scanner files
ifneq ($(wildcard $(SCANNER_C)),)
    SOURCES += $(SCANNER_C)
endif
ifneq ($(wildcard $(SCANNER_CPP)),)
    SOURCES += $(SCANNER_CPP)
endif

# Object files
OBJECTS := $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.cc=.o)

# Default target
all: generate $(LIBNAME)

# Generate parser code from grammar.json
generate:
	@tree-sitter generate grammar.json

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

%.o: %.cc
	$(CXX) $(CFLAGS) $< -o $@

# Link object files into dynamic library
$(LIBNAME): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $@

# Clean up
clean:
	rm -f $(SRC_DIR)/*.o $(LIBNAME)

# Phony targets
.PHONY: all generate clean
