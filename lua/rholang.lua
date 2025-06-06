-- lua/rholang.lua
local M = {}

function M.setup()
  -- Set filetype for .rho files
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.rho' },
    command = 'setfiletype rholang',
  })

  -- Enable Tree-sitter for Rholang
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'rholang',
    callback = function()
      -- Ensure Tree-sitter parser is enabled
      local ok, ts = pcall(require, 'nvim-treesitter.configs')
      if ok then
        ts.setup {
          ensure_installed = { 'rholang' }, -- Ensure parser is installed
          highlight = {
            enable = true, -- Enable Tree-sitter highlighting
            additional_vim_regex_highlighting = false, -- Disable legacy regex highlighting
          },
        }
      else
        vim.notify('nvim-treesitter not installed, falling back to legacy syntax', vim.log.levels.WARN)
      end

      -- LSP configuration
      local root_dir = vim.fs.dirname(
        vim.fs.find({ '.git', 'rholang.toml' }, { upward = true })[1] or '.'
      )
      local client_id = vim.lsp.start({
        name = 'rholang',
        cmd = {
          'rholang-language-server',
          '--no-color',
          '--stdio',
          '--log-level', 'debug',
          '--client-process-id', tostring(vim.fn.getpid()),
        },
        root_dir = root_dir,
        on_error = function(err)
          vim.notify('LSP error: ' .. vim.inspect(err), vim.log.levels.ERROR)
        end,
      })
      if client_id then
        vim.notify(
          'LSP client for rholang-language-server started with ID: ' .. client_id,
          vim.log.levels.DEBUG
        )
      else
        vim.notify(
          'Failed to start rholang-language-server',
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

return M
