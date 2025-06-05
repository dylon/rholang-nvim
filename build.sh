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
elif [[ "$OS" == "Darwin" ]]; then
    command -v clang >/dev/null 2>&1 || { echo "clang is required. Install Xcode or command line tools."; exit 1; }
elif [[ "$OS" == "Windows_NT" ]]; then
    command -v cl.exe >/dev/null 2>&1 || { echo "cl.exe is required. Install Visual Studio Build Tools."; exit 1; }
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Ensure grammar.json exists
if [ ! -f "grammar.json" ]; then
    echo "grammar.json not found in current directory"
    exit 1
fi

# Run make
make

echo "Build successful: libtree-sitter-rholang.$EXT created"
