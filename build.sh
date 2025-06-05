#!/bin/bash

# Cross-platform build script for Tree-sitter Rholang parser

# Exit on error
set -e

# Check for required dependencies
command -v node >/dev/null 2>&1 || { echo "Node.js is required. Please install it."; exit 1; }
command -v tree-sitter >/dev/null 2>&1 || { echo "tree-sitter CLI is required. Install with 'npm install -g tree-sitter-cli'."; exit 1; }

# Detect OS for compiler check
OS=$(uname -s)
if [[ "$OS" == "Linux" ]]; then
    command -v gcc >/dev/null 2>&1 || { echo "gcc is required. Please install it."; exit 1; }
    command -v g++ >/dev/null 2>&1 || { echo "g++ is required. Please install it."; exit 1; }
    EXT=so
elif [[ "$OS" == "Darwin" ]]; then
    command -v clang >/dev/null 2>&1 || { echo "clang is required. Install Xcode or command line tools."; exit 1; }
    EXT=dylib
elif [[ "$OS" == "Windows_NT" ]]; then
    command -v cl.exe >/dev/null 2>&1 || { echo "cl.exe is required. Install Visual Studio Build Tools."; exit 1; }
    EXT=dll
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Ensure grammar.js exists
if [ ! -f "grammar.js" ]; then
    echo "grammar.js not found in current directory"
    exit 1
fi

# Warn if tree-sitter.json is missing
if [ ! -f "tree-sitter.json" ]; then
    echo "Warning: tree-sitter.json not found. Creating one with ABI 15."
    echo '{"abi_version": 15, "name": "rholang"}' > tree-sitter.json
fi

# Run make to build and install
make && make install

echo "Build and installation successful: libtree-sitter-rholang.$EXT installed to Neovim parser directory"
