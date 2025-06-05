-- lua/rholang/health.lua
local health = vim.health or require('health')

local M = {}

-- Helper function to get rholang configuration
local function get_config()
  local ok, rholang = pcall(require, 'rholang')
  if ok and (rholang.config or rholang.default_config) then
    return rholang.config or rholang.default_config
  end
  health.warn('rholang-nvim configuration not found. Using default values.')
  return {
    lsp = { enable = true, log_level = 'debug', language_server_path = 'rholang-language-server' },
    treesitter = { enable = true, highlight = true, indent = true, fold = true },
  }
end

-- Helper function to check if a command is executable
local function check_executable(cmd, name)
  if vim.fn.executable(cmd) == 1 then
    health.ok(name .. ' is installed and executable')
  else
    health.error(name .. ' is not installed or not executable. Ensure it is in your PATH.')
  end
end

-- Helper function to check Neovim version
local function check_neovim_version()
  local version = vim.version()
  local major, minor = version.major, version.minor
  if major >= 0 and minor >= 11 then
    health.ok('Neovim version ' .. major .. '.' .. minor .. ' meets requirement (>= 0.11.0)')
  else
    health.error('Neovim version ' .. major .. '.' .. minor .. ' is too old. Requires >= 0.11.0 for nvim-treesitter main branch.')
  end
end

-- Helper function to check if a module is installed
local function check_module(module_name, module_description)
  local ok, _ = pcall(require, module_name)
  if ok then
    health.ok(module_description .. ' is installed')
  else
    health.error(module_description .. ' is not installed. Install via your plugin manager.')
  end
  return ok
end

-- Helper function to check if Tree-sitter parser is installed
local function check_treesitter_parser()
  local ok, ts_config = pcall(require, 'nvim-treesitter.config')
  if not ok then
    health.error('nvim-treesitter.config module is not available. Ensure nvim-treesitter is properly set up.')
    return false
  end
  local installed_parsers = ts_config.get_installed('parsers') or {}
  local has_parser = vim.tbl_contains(installed_parsers, 'rholang')
  if has_parser then
    health.ok('Tree-sitter parser for Rholang is installed')
  else
    health.error('Tree-sitter parser for Rholang is not installed. Run `:TSInstall rholang`.')
  end
  return has_parser
end

-- Helper function to check Tree-sitter configuration
local function check_treesitter_config()
  local ok, ts_config = pcall(require, 'nvim-treesitter.config')
  if not ok then
    health.error('nvim-treesitter.config module is not available. Ensure nvim-treesitter is properly set up.')
    return
  end
  -- Since main branch doesn't use configs.get_module, check if features are enabled via setup
  local config = get_config()
  local features = { 'highlight', 'indent', 'fold' }
  for _, feature in ipairs(features) do
    if config.treesitter[feature] then
      health.ok('Tree-sitter ' .. feature .. ' is enabled')
    else
      health.warn('Tree-sitter ' .. feature .. ' is disabled. Enable it in rholang-nvim config.')
    end
  end
end

-- Helper function to check compiler availability
local function check_compiler()
  local compilers = {
    linux = { 'gcc', 'g++' },
    macos = { 'clang' },
    windows = { 'cl.exe' },
  }
  local os_name = vim.loop.os_uname().sysname:lower()
  local os_key = os_name:match('linux') and 'linux' or os_name:match('darwin') and 'macos' or 'windows'
  local compiler_list = compilers[os_key] or {}
  for _, compiler in ipairs(compiler_list) do
    if vim.fn.executable(compiler) == 1 then
      health.ok('Compiler ' .. compiler .. ' is available for ' .. os_key)
      return
    end
  end
  health.error('No required compiler found for ' .. os_key .. '. Required: ' .. table.concat(compiler_list, ' or ') .. '.')
end

-- Helper function to check LSP server
local function check_lsp_server()
  local config = get_config()
  if not config.lsp.enable then
    health.info('LSP is disabled in rholang-nvim configuration.')
    return
  end
  local lsp_path = config.lsp.language_server_path
  check_executable(lsp_path, 'rholang-language-server')
  local clients = vim.lsp.get_clients({ name = 'rholang' })
  if #clients > 0 then
    health.ok('rholang-language-server is running (client ID: ' .. clients[1].id .. ')')
  else
    health.warn('rholang-language-server is not running. Open a .rho file to start it or check LSP configuration.')
  end
end

-- Helper function to check filetype detection
local function check_filetype_detection()
  local test_file = vim.fn.tempname() .. '.rho'
  -- Write an empty file using a list as required by writefile
  vim.fn.writefile({}, test_file)
  local bufnr = vim.fn.bufadd(test_file)
  vim.fn.bufload(bufnr)
  local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  vim.fn.delete(test_file)
  if ft == 'rholang' then
    health.ok('Filetype detection for .rho files is working')
  else
    health.error('Filetype detection for .rho files failed. Expected "rholang", got "' .. ft .. '".')
  end
end

-- Helper function to check syntax highlighting
local function check_syntax_highlighting()
  local config = get_config()
  if not config.treesitter.enable then
    health.info('Tree-sitter is disabled in rholang-nvim configuration; falling back to legacy syntax.')
    local syntax = vim.api.nvim_buf_get_option(0, 'syntax')
    if syntax == 'rholang' then
      health.ok('Legacy syntax highlighting is enabled')
    else
      health.error('Legacy syntax highlighting is not enabled. Expected syntax=rholang, got ' .. syntax)
    end
    return
  end
  local parser_ok = check_treesitter_parser()
  if parser_ok then
    local sample_code = [[
new input, output in {
  for (@message <- input) {
    output!(message)
  }
}
]]
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(sample_code, '\n'))
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'rholang')
    local ok, err = pcall(vim.treesitter.start, bufnr, 'rholang')
    if not ok then
      health.error('Tree-sitter syntax highlighting failed to initialize: ' .. tostring(err))
      vim.api.nvim_buf_delete(bufnr, { force = true })
      return
    end
    local highlighter = vim.treesitter.get_parser(bufnr, 'rholang')
    if highlighter then
      health.ok('Tree-sitter syntax highlighting is functional')
    else
      health.error('Tree-sitter syntax highlighting failed to initialize.')
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Main health check function
function M.check()
  health.start('rholang-nvim: Plugin Health Check')

  health.start('Checking Neovim version')
  check_neovim_version()

  health.start('Checking dependencies')
  check_executable('tree-sitter', 'Tree-sitter CLI')
  local has_treesitter = check_module('nvim-treesitter', 'nvim-treesitter plugin')
  check_compiler()

  health.start('Checking Tree-sitter configuration')
  if has_treesitter then
    check_treesitter_config()
    check_syntax_highlighting()
  else
    health.error('Skipping Tree-sitter checks due to missing nvim-treesitter plugin.')
  end

  health.start('Checking LSP configuration')
  check_lsp_server()

  health.start('Checking filetype detection')
  check_filetype_detection()
end

return M
