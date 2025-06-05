# Rholang Neovim Plugin

This Neovim plugin provides comprehensive language support for [Rholang](https://github.com/F1R3FLY-io/f1r3fly), a concurrent, process-oriented programming language. It leverages Tree-sitter for syntax highlighting, indentation, folding, and text objects, and integrates with [rholang-language-server](https://github.com/F1R3FLY-io/rholang-language-server) for LSP features in `.rho` files.

## Features

- **Tree-sitter Syntax Highlighting**: Highlights Rholang keywords (`contract`, `new`, `for`, etc.), strings, URIs, numbers, operators, variables, and comments.
- **LSP Integration**: Provides autocompletion, diagnostics, go-to-definition, and more via `rholang-language-server`.
- **Automatic Indentation**: Smart indentation for blocks (`{}`), lists (`[]`), tuples (`()`), and other constructs, with custom `<CR>`, `o`, and `O` keymaps.
- **Delimiter Handling**: Auto-closes `{`, `(`, `[`, and `"` with matching pairs, skips closing delimiters, and deletes empty pairs or strings (`""`) using `<BS>`, `<DEL>`, `x`, or `X`.
- **Folding**: Tree-sitter-based folding for `contract`, `block`, `input`, `match`, `choice`, `new`, `par`, and `method` nodes.
- **Text Objects**: Navigate and select code blocks, strings, and variables with Tree-sitter text objects.
- **Legacy Syntax Support**: Fallback Vim syntax highlighting (`syntax/rholang.vim`) for environments without Tree-sitter.

## Prerequisites

- Neovim v0.9.0 or later (required for Tree-sitter support)
- [Tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/using-parsers#installation) (`npm install -g tree-sitter-cli`)
- [`rholang-language-server`](https://github.com/F1R3FLY-io/rholang-language-server) installed and in your system PATH
- Compiler tools:
  - Linux: `gcc`, `g++`
  - macOS: `clang` (via Xcode or command line tools)
  - Windows: `cl.exe` (via Visual Studio Build Tools)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for Tree-sitter parsing

## Installation

### Using a Plugin Manager

#### lazy.nvim

Add to your `lazy.nvim` configuration in `init.lua`:

```lua
{
  'F1R3FLY-io/rholang-nvim',
  config = function()
    require('rholang').setup()
  end,
  build = function()
    local cmd = 'cd ' .. vim.fn.expand('<sfile>:p:h') .. ' && make && make install'
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify('rholang-nvim build failed: ' .. result, vim.log.levels.ERROR)
    else
      vim.notify('rholang-nvim build successful', vim.log.levels.INFO)
    end
  end,
}
```

#### packer.nvim

Add to your `packer.nvim` configuration:

```lua
use {
  'F1R3FLY-io/rholang-nvim',
  config = function()
    require('rholang').setup()
  end,
  run = ':make && make install',
}
```

#### vim-plug

Add to your `vim-plug` configuration:

```vim
Plug 'F1R3FLY-io/rholang-nvim', { 'do': 'make && make install' }
```

Then, in your `init.lua`:

```lua
require('rholang').setup()
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/F1R3FLY-io/rholang-nvim.git ~/.local/share/nvim/site/pack/rholang/start/rholang-nvim
```

2. Compile and install the Tree-sitter parser:

```bash
cd ~/.local/share/nvim/site/pack/rholang/start/rholang-nvim
make && make install
```

Alternatively, use the build script:

```bash
./build.sh
```

3. Install the Rholang Tree-sitter parser in Neovim:

```vim
:TSInstall rholang
```

### Tree-sitter Parser Setup

Ensure `nvim-treesitter` is installed and configured:

```lua
{
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'rholang' },
      highlight = { enable = true },
      indent = { enable = true },
      fold = { enable = true },
    }
  end,
}
```

## Local Development

For local development, clone the repository to a custom path and use the `dir` parameter. Example for `lazy.nvim`:

```lua
{
  'F1R3FLY-io/rholang-nvim',
  dir = '~/path/to/rholang-nvim',
  config = function()
    require('rholang').setup {
      lsp = {
        enable = true,
        log_level = 'debug',
        language_server_path = 'rholang-language-server',
      },
      treesitter = {
        enable = true,
        highlight = true,
        indent = true,
        fold = true,
      },
    }
  end,
  build = function()
    local cmd = 'cd ~/path/to/rholang-nvim && make && make install'
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify('rholang-nvim build failed: ' .. result, vim.log.levels.ERROR)
    else
      vim.notify('rholang-nvim build successful', vim.log.levels.INFO)
    end
  end,
}
```

Register the local Tree-sitter parser:

```lua
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'rholang' },
}
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = function()
    require('nvim-treesitter.parsers').rholang = {
      install_info = {
        path = '~/path/to/rholang-nvim',
        generate = true,
        queries = 'queries/rholang',
      },
      maintainers = { '@your-username' },
      tier = 2, -- Unstable, local parser
    }
  end,
})
```

Build and test locally:

```bash
cd ~/path/to/rholang-nvim
./build.sh
nvim -u NONE -c 'TSInstall rholang' -c 'q'
```

## Usage

1. Open a `.rho` file (e.g., `test.rho`):

```rholang
new input, output in {
    for (@message <- input) {
        output!(message)
    }
}
```

2. The plugin automatically:
   - Applies Tree-sitter syntax highlighting, indentation, and folding (if `treesitter.enable = true`).
   - Starts `rholang-language-server` for LSP features (if `lsp.enable = true`).
   - Enables delimiter auto-closing and deletion for `{`, `(`, `[`, and `"`.

3. Key features:
   - **Delimiters**: Type `{`, `(`, `[`, or `"` to auto-close; press `<BS>`, `<DEL>`, `x`, or `X` on empty pairs (e.g., `{}`, `""`) to delete both.
   - **Indentation**: Press `<CR>`, `o`, or `O` to indent new lines within blocks, lists, etc.
   - **Folding**: Use `:set foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()` and `zc`/`zo` to fold/unfold code blocks.
   - **Text Objects**: Select code blocks or strings with `:lua vim.treesitter.textobjects.select('@block.outer')`.
   - **LSP**: Use autocompletion (`<C-x><C-o>`), diagnostics, and go-to-definition.

## File Structure

```
rholang-nvim
├── build.sh                     # Build script for Tree-sitter parser
├── CMakeLists.txt               # CMake build configuration
├── ftplugin
│   └── rholang.lua              # Filetype-specific settings
├── grammar.js                   # Tree-sitter grammar for Rholang
├── lua
│   └── rholang.lua              # Plugin setup, LSP, Tree-sitter config
├── Makefile                     # Makefile for parser compilation
├── queries
│   └── rholang
│       ├── folds.scm            # Folding rules
│       ├── highlights.scm       # Highlighting rules
│       ├── indents.scm          # Indentation rules
│       ├── locals.scm           # Variable definitions/references
│       └── textobjects.scm      # Text object definitions
├── syntax
│   └── rholang.vim              # Legacy Vim syntax highlighting
├── LICENSE.TXT                  # License file
└── README.md                    # This file
```

## Configuration

Configure the plugin via `require('rholang').setup(config)`. Default settings:

```lua
{
  lsp = {
    enable = true,
    log_level = 'debug', -- Options: error, warn, info, debug, trace
    language_server_path = 'rholang-language-server',
  },
  treesitter = {
    enable = true,
    highlight = true,
    indent = true,
    fold = true,
  },
}
```

### Examples

- **Disable Tree-sitter** (use legacy syntax):

```lua
require('rholang').setup({
  treesitter = {
    enable = false,
  },
})
```

- **Change LSP log level**:

```lua
require('rholang').setup({
  lsp = {
    log_level = 'info',
  },
})
```

- **Custom LSP command**:

```lua
require('rholang').setup()
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rholang',
  callback = function()
    vim.lsp.start({
      name = 'rholang',
      cmd = {
        'rholang-language-server',
        '--no-color',
        '--stdio',
        '--log-level', 'trace',
        '--client-process-id', tostring(vim.fn.getpid()),
      },
      root_dir = vim.fs.dirname(
        vim.fs.find({ '.git', 'rholang.toml' }, { upward = true })[1] or '.'
      ),
    })
  end,
})
```

## Troubleshooting

- **Tree-sitter errors**: Run `:TSInstall rholang` and compile the parser (`make && make install` or `./build.sh`).
- **LSP not starting**: Ensure `rholang-language-server` is in your PATH and executable or specify its path in the config via `lsp.language_server_path`.
- **Indentation issues**: Verify `:set indentexpr=v:lua.require'nvim-treesitter'.indentexpr()` and `treesitter.indent = true`.
- **Build failures**: Check for `gcc`/`g++` (Linux), `clang` (macOS), or `cl.exe` (Windows). Run `./build.sh` for diagnostics.
- **Debugging**: Enable LSP logging:
  ```vim
  :lua vim.lsp.set_log_level('debug')
  :LspLog
  ```

## Health Check

Run `:checkhealth rholang` to verify the plugin's setup. The health check ensures that all components are correctly installed and configured, including:

- Neovim version (>= 0.11.0)
- Dependencies: Tree-sitter CLI, `nvim-treesitter` plugin, and appropriate compilers (`gcc`/`g++` for Linux, `clang` for macOS, or `cl.exe` for Windows)
- Tree-sitter configuration: Parser installation, syntax highlighting, indentation, and folding
- LSP configuration: Availability and running status of `rholang-language-server`
- Filetype detection for `.rho` files

A successful health check output looks like:

```text
rholang-nvim: Plugin Health Check

Checking Neovim version
- OK Neovim version 0.11 meets requirement (>= 0.11.0)

Checking dependencies
- OK Tree-sitter CLI is installed and executable
- OK nvim-treesitter plugin is installed
- OK Compiler gcc is available for linux

Checking Tree-sitter configuration
- OK Tree-sitter highlight is enabled
- OK Tree-sitter indent is enabled
- OK Tree-sitter fold is enabled
- OK Tree-sitter parser for Rholang is installed
- OK Tree-sitter syntax highlighting is functional

Checking LSP configuration
- OK rholang-language-server is installed and executable
- OK rholang-language-server is running (client ID: 1)

Checking filetype detection
- OK Filetype detection for .rho files is working
```

If issues are reported, refer to the [Troubleshooting](#troubleshooting) section for guidance on resolving them.

## License

Licensed under the terms in `LICENSE.TXT`.

## Contributing

Submit issues or pull requests to the [rholang-nvim repository](https://github.com/F1R3FLY-io/rholang-nvim).

## Related Projects

- [rholang-language-server](https://github.com/F1R3FLY-io/rholang-language-server)
- [Rholang](https://github.com/F1R3FLY-io/f1r3fly)

## Version

0.3.0 (June 10, 2025)