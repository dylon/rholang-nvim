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
    - For example, with [vim-plug](https://github.com/junegunn/vim-plug): `Plug 'F1R3FLY-io/rholang-nvim'`
2. Add the following to your `init` file to ensure the extension has been initialized:
    ```lua
    local ok, err = pcall(require('rholang').setup)
    if not ok then
      vim.notify('Failed to setup rholang-nvim: ' .. err, vim.log.levels.ERROR)
    end
    ```
    - If you use VimScript for your configuration, wrap it in `lua << EOF` and `EOF`:
        ```lua
        lua << EOF
        local ok, err = pcall(require('rholang').setup)
        if not ok then
          vim.notify('Failed to setup rholang-nvim: ' .. err, vim.log.levels.ERROR)
        end
        EOF
        ```
3. Ensure the Rholang LSP server binary (`rholang-language-server`) is in the
   extension’s `$PATH`.
4. Start the `rnode` server: `rnode run --standalone`.

## Usage
- Open a `.rho` file in VS Code.
- Edit the file to see diagnostics for Rholang errors.

## Recommended extensions
- [trouble.nvim](https://github.com/folke/trouble.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
