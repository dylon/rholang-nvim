-- lua/rholang.lua
local M = {}

function M.setup()
  -- Set filetype for .rho files
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = {'*.rho'},
    command = 'setfiletype rholang',
  })

  -- LSP configuration
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'rholang',
    callback = function()
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
