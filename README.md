# Neovim support for Rholang (LSP Client)

Provides language support for Rholang (.rho) files in Neovim, including
diagnostics via an LSP-based language server
([rholang-language-server](https://github.com/f1R3FLY-io/rholang-language-server)).

## Features
- Syntax validation for Rholang files using an external `rnode` server.
- Diagnostics for errors (e.g., syntax errors, unbound variables).
- Incremental text synchronization for efficient editing.

## Requirements
- **Rholang LSP Server**: Compile the server from the source (requires Rust and
  Cargo).
- **rnode**: Run `rnode run --standalone` to provide gRPC validation.
- **Neovim**: Version 0.5 or later.

## Installation
1. Install the extension with your favorite extension for Neovim from this repository.
2. Ensure the Rholang LSP server binary (`rholang-language-server`) is in the
   extension’s `$PATH`.
3. Start the `rnode` server: `rnode run --standalone`.

## Usage
- Open a `.rho` file in VS Code.
- Edit the file to see diagnostics for Rholang errors.

## Recommended extensions
- [trouble.nvim](https://github.com/folke/trouble.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
