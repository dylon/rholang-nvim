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
    pattern = {'*.rho'},
    callback = function()
      local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'rholang.toml' }, { upward = true })[1] or '.')
      local client = vim.lsp.start({
        name = 'rholang',
        cmd = { 'rholang-language-server' },
        root_dir = root_dir,
      })
      vim.lsp.buf_attach_client(0, client)
    end,
  })
end

return M
