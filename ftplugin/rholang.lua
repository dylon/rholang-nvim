-- ftplugin/rholang.lua
vim.bo.commentstring = '// %s'
vim.bo.comments = 's1:/*,mb:*,ex:*/,://,:///'

vim.bo.autoindent = true
vim.bo.smartindent = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

vim.api.nvim_buf_set_option(0, 'matchpairs', '(:),{:},[:]')

-- Disable legacy syntax highlighting if Tree-sitter is enabled
if vim.treesitter.language.get_lang('rholang') then
  vim.bo.syntax = 'off'
end
