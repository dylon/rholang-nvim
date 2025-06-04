# Rholang Neovim Plugin

This Neovim plugin provides language support for
[Rholang](https://github.com/F1R3FLY-io/f1r3fly). It includes syntax
highlighting, LSP integration with `rholang-language-server`, and automatic
indentation for `.rho` files.

## Features

- **Syntax Highlighting**: Supports Rholang keywords, strings, URIs, numbers,
operators, and more.
- **LSP Integration**: Connects to
[rholang-language-server](https://github.com/F1R3FLY-io/rholang-language-server)
for autocompletion, diagnostics, and other language features.
- **Automatic Indentation**: Automatically indents new lines with respect to
the previous ones.

## Installation

### Prerequisites

- Neovim (v0.5.0 or later)
- [`rholang-language-server`](https://github.com/F1R3FLY-io/rholang-language-server)
installed and accessible in your system PATH
- [`rnode`](https://github.com/F1R3FLY-io/f1r3fly) installed and accessible in
your system PATH.

### Using a Plugin Manager

#### lazy.nvim

Add the following to your `lazy.nvim` configuration:

```lua
{
  'F1R3FLY-io/rholang-nvim',
  config = function()
    require('rholang').setup()
  end,
}
```

#### packer.nvim

Add the following to your `packer.nvim` configuration:

```lua
use {
  'F1R3FLY-io/rholang-nvim',
  config = function()
    require('rholang').setup()
  end,
}
```

### Manual Installation

1. Clone the repository into your Neovim runtime path:

```bash
git clone https://github.com/F1R3FLY-io/rholang-nvim.git ~/.local/share/nvim/site/pack/rholang/start/rholang-nvim
```

2. Add the following to your Neovim configuration (e.g., `init.lua`):

```lua
require('rholang').setup()
```

## Usage

1. Open a `.rho` file in Neovim.
2. The plugin will:
   - Set the filetype to `rholang`.
   - Start the `rholang-language-server` with the current Neovim instance's
   PID.
   - Apply syntax highlighting and formatting settings.
3. Use LSP features like autocompletion, go-to-definition, and diagnostics
provided by the language server.

## File Structure

```
rholang-nvim
├── ftplugin
│   └── rholang.lua      # Filetype-specific settings (indentation, comments, etc.)
├── lua
│   └── rholang.lua      # LSP and filetype detection setup
├── syntax
│   └── rholang.vim      # Syntax highlighting for Rholang
├── LICENSE.TXT          # License file
└── README.md            # This file
```

## Configuration

The plugin is configured automatically when you call
`require('rholang').setup()`. You can customize LSP settings by modifying
`lua/rholang.lua` or overriding the `cmd` table in your Neovim configuration.

For example, to change the log level of the language server:

```lua
require('rholang').setup()
-- Override LSP command
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rholang',
  callback = function()
    vim.lsp.start({
      name = 'rholang',
      cmd = {
        'rholang-language-server',
        '--no-color',
        '--stdio',
        '--log-level', 'info', -- Changed from 'debug' to 'info'
        '--client-process-id', tostring(vim.fn.getpid()),
      },
      root_dir = vim.fs.dirname(
        vim.fs.find({ '.git', 'rholang.toml' }, { upward = true })[1] or '.'
      ),
    })
  end,
})
```

## License

This plugin is licensed under the terms specified in `LICENSE.TXT`.

## Contributing

Contributions are welcome! Please submit issues or pull requests to the
[rholang-nvim repository](https://github.com/F1R3FLY-io/rholang-nvim).

## Related Projects

- [rholang-language-server](https://github.com/F1R3FLY-io/rholang-language-server): The LSP server for Rholang.
- [RNode](https://github.com/F1R3FLY-io/f1r3fly): The RNode implementation.
