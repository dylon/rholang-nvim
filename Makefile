# Makefile for cross-platform Tree-sitter parser compilation and installation

# Detect operating system
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    OS := linux
    EXT := so
    CC := gcc
    CXX := g++
    CFLAGS := -c -fPIC -I./src -O2 -g
    LDFLAGS := -shared
    PARSER_DIR := $(HOME)/.local/share/nvim/site/parser
    QUERY_DIR := $(HOME)/.local/share/nvim/site/queries/rholang
    MKDIR := mkdir -p
    CP := cp
    RM := rm -f
endif
ifeq ($(UNAME_S),Darwin)
    OS := macos
    EXT := dylib
    CC := clang
    CXX := clang++
    CFLAGS := -c -fPIC -I./src -O2 -g
    LDFLAGS := -dynamiclib -Wl,-install_name,rholang.$(EXT)
    PARSER_DIR := $(HOME)/.local/share/nvim/site/parser
    QUERY_DIR := $(HOME)/.local/share/nvim/site/queries/rholang
    MKDIR := mkdir -p
    CP := cp
    RM := rm -f
endif
ifeq ($(OS),Windows_NT)
    OS := windows
    EXT := dll
    CC := cl.exe
    CXX := cl.exe
    CFLAGS := /c /I.\src /O2 /Zi
    LDFLAGS := /DLL /OUT:rholang.$(EXT)
    PARSER_DIR := $(USERPROFILE)\AppData\Local\nvim\site\parser
    QUERY_DIR := $(USERPROFILE)\AppData\Local\nvim\site\queries\rholang
    MKDIR := mkdir
    CP := copy
    RM := del /Q
endif

# Output library name
LIBNAME := rholang.$(EXT)

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

# Query files
QUERY_SRC_DIR := queries/rholang
QUERY_FILES := $(wildcard $(QUERY_SRC_DIR)/*.scm)

# Default target
all: generate $(LIBNAME)

# Generate parser code from grammar.js
generate:
	@tree-sitter generate grammar.js

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

%.o: %.cc
	$(CXX) $(CFLAGS) $< -o $@

# Link object files into dynamic library
$(LIBNAME): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $@

# Install the library and query files
install: $(LIBNAME)
	@$(MKDIR) "$(PARSER_DIR)"
	@$(CP) $(LIBNAME) "$(PARSER_DIR)/$(LIBNAME)"
	@echo "Installed $(LIBNAME) to $(PARSER_DIR)"
	@if [ -n "$(QUERY_FILES)" ]; then \
		$(MKDIR) "$(QUERY_DIR)"; \
		$(CP) $(QUERY_SRC_DIR)/*.scm "$(QUERY_DIR)/"; \
		echo "Installed query files to $(QUERY_DIR)"; \
	else \
		echo "No query files found in $(QUERY_SRC_DIR)"; \
	fi

# Clean up
clean:
	$(RM) $(SRC_DIR)/*.o $(LIBNAME)

# Phony targets
.PHONY: all generate install clean
