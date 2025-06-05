-- lua/rholang.lua
local M = {}

-- Default configuration
local default_config = {
  lsp = {
    enable = true,
    log_level = 'debug', -- Options: error, warn, info, debug, trace
    language_server_path = 'rholang-language-server', -- Path to the language server executable
  },
  treesitter = {
    enable = true,
    highlight = true,
    indent = true,
    fold = true,
  },
}

-- Merge user config with defaults
local function merge_configs(user_config)
  return vim.tbl_deep_extend('force', default_config, user_config or {})
end

function M.setup(user_config)
  local config = merge_configs(user_config)

  -- Register language for filetypes
  vim.treesitter.language.register('rholang', 'rholang')

  -- Set filetype for .rho files
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.rho' },
    callback = function()
      vim.bo.filetype = 'rholang'
    end,
  })

  -- Configure Tree-sitter, filetype settings, and LSP for rholang
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'rholang',
    callback = function()
      -- Apply Tree-sitter settings
      if config.treesitter.enable then
        local ok, err = pcall(function()
          if config.treesitter.highlight then
            vim.treesitter.start(nil, 'rholang') -- Highlighting
          end
          if config.treesitter.fold then
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Folds
          end
          if config.treesitter.indent then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- Indentation
          end
        end)
        if not ok then
          vim.notify('Failed to load Rholang parser: ' .. tostring(err), vim.log.levels.ERROR)
          vim.notify('Falling back to legacy syntax', vim.log.levels.WARN)
          vim.bo.syntax = 'rholang'
        end
      else
        vim.bo.syntax = 'rholang' -- Fallback to legacy syntax if Tree-sitter is disabled
      end

      -- Filetype settings
      vim.bo.commentstring = '// %s'
      vim.bo.comments = 's1:/*,mb:*,ex:*/,://'
      vim.bo.autoindent = true
      vim.bo.smartindent = false
      vim.bo.matchpairs = '(:),{:},[:],":"'

      -- Define valid node types for delimiter handling
      local valid_node_types = {
        block = { open = '{', close = '}' },
        map = { open = '{', close = '}' },
        match = { open = '{', close = '}' },
        choice = { open = '{', close = '}' },
        list = { open = '[', close = ']' },
        tuple = { open = '(', close = ')' },
        inputs = { open = '(', close = ')' },
      }

      -- Check if cursor is inside {}, (), or [] in relevant nodes
      local function delimited_node(row, col)
        local parser = vim.treesitter.get_parser(0, 'rholang')
        local tree = parser:parse()[1]
        local node = tree:root():named_descendant_for_range(row, col, row, col)
        while node do
          local node_type = node:type()
          local delim_info = valid_node_types[node_type]
          if delim_info then
            local start_row, start_col, end_row, end_col = node:range()
            local cursor_pos = vim.api.nvim_buf_get_offset(0, row) + col
            local open_pos = vim.api.nvim_buf_get_offset(0, start_row) + start_col
            local close_pos = vim.api.nvim_buf_get_offset(0, end_row) + end_col
            if cursor_pos >= open_pos and cursor_pos <= close_pos then
              return node, delim_info
            end
            break
          end
          node = node:parent()
        end
        return nil, nil
      end

      -- Helper function to check if next character matches the closing delimiter
      local function skip_if_next_char_is(char)
        local line = vim.api.nvim_get_current_line()
        local _, col = unpack(vim.api.nvim_win_get_cursor(0))
        col = col - 1 -- Convert to 0-based
        if line:sub(col + 2, col + 2) == char then
          return '<Right>'
        else
          return char
        end
      end

      -- Generate indent string based on global settings
      local function get_indent_string(level)
        if vim.o.expandtab then
          return string.rep(' ', level * vim.o.shiftwidth)
        else
          return string.rep('\t', level)
        end
      end

      -- Returns size of single indentation in terms of tabs or spaces
      local function indent()
        if vim.o.expandtab then
          return vim.o.shiftwidth
        else
          return vim.o.tabstop
        end
      end

      -- Check if a node contains only whitespace between delimiters
      local function is_node_whitespace_only(node)
        local start_row, start_col, end_row, end_col = node:range()
        -- Extract text between delimiters (exclude the delimiters themselves)
        start_col = start_col + 1  -- discard the opening delimiter
        end_col = end_col - 1  -- discard the closing delimiter
        if start_row == end_row and start_col == end_col then
          return true
        end
        local inner_text = table.concat(vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {}), '\n')
        return inner_text:match('^%s*$') ~= nil
      end

      -- Handle deletion for <BS>, <DEL> in insert mode, and x, X in normal mode
      local function handle_delete(is_forward, is_insert_mode)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1 -- Convert to 0-based
        local line = vim.api.nvim_get_current_line()
        local check_col = is_forward and col or (col > 0 and col - 1 or 0)
        local char_to_check = line:sub(check_col + 1, check_col + 1)
        local node, delim_info = delimited_node(row, check_col)

        -- Handle deletion of empty string ("") when on opening quote
        if char_to_check == '"' then
          local parser = vim.treesitter.get_parser(0, 'rholang')
          local tree = parser:parse()[1]
          local string_node = tree:root():named_descendant_for_range(row, check_col, row, check_col)
          if string_node and string_node:type() == "string_literal" then
            local text = vim.treesitter.get_node_text(string_node, 0)
            if text == '""' then
              vim.schedule(function()
                local start_row, start_col, end_row, end_col = string_node:range()
                vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { '' })
                vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
              end)
              return ''
            end
          end
        end

        if node and char_to_check == delim_info.open and is_node_whitespace_only(node) then
          vim.schedule(function()
            local start_row, start_col, end_row, end_col = node:range()
            vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { '' })
            vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
          end)
          return ''
        else
          if is_insert_mode then
            return is_forward and '<Del>' or '<BS>'
          else
            return is_forward and 'x' or 'X'
          end
        end
      end

      -- Helper function to handle <CR> behavior at a given position
      local function handle_return(curr_row, curr_col)
        local node, _ = delimited_node(curr_row, curr_col)
        local curr_line = curr_row + 1 -- 1-based line number
        local indent_width = indent()
        local curr_indent = vim.fn.indent(curr_line)
        local next_indent = curr_indent + indent_width
        local curr_spaces = get_indent_string(math.floor(curr_indent / indent_width))
        local line_text = vim.api.nvim_buf_get_lines(0, curr_row, curr_row + 1, false)[1] or ''
        local new_lines = nil

        if node then
          local start_row, start_col, end_row, end_col = node:range()
          local before_cursor = line_text:sub(1, curr_col):gsub('%s+$', '')
          local after_cursor = line_text:sub(curr_col + 1):gsub('^%s*(.-)%s*$', '%1')
          local next_spaces = get_indent_string(math.floor(next_indent / indent_width))
          local after_len = #after_cursor
          if after_len == 0 then
            if curr_row > start_row then
              next_indent = curr_indent
              next_spaces = get_indent_string(math.floor(next_indent / indent_width))
            end
            new_lines = {
              before_cursor,
              next_spaces,
            }
          elseif after_len == 1 then
            local before_len = #before_cursor:gsub('^%s+', '')
            if before_len > 0 then
              new_lines = {
                before_cursor,
                next_spaces,
                curr_spaces .. after_cursor,
              }
            else
              next_indent = curr_indent - indent_width
              next_spaces = get_indent_string(math.floor(next_indent / indent_width))
              new_lines = {
                before_cursor,
                next_spaces .. after_cursor,
              }
            end
          else
            new_lines = {
              before_cursor,
              next_spaces .. after_cursor,
            }
          end
        else
          -- Default behavior when not in delimiters
          next_indent = curr_indent
          new_lines = {
            line_text,
            curr_spaces,
          }
        end

        vim.schedule(function()
          local next_row = curr_row + 1
          local next_line = curr_line + 1
          vim.api.nvim_buf_set_lines(0, curr_row, next_row, false, new_lines)
          vim.api.nvim_win_set_cursor(0, { next_line, next_indent })
          vim.api.nvim_command('startinsert')
        end)
      end

      -- Keymaps for inserting paired delimiters
      vim.keymap.set('i', '{', function()
        return '{}<Left>'
      end, { expr = true, buffer = true })

      vim.keymap.set('i', '(', function()
        return '()<Left>'
      end, { expr = true, buffer = true })

      vim.keymap.set('i', '[', function()
        return '[]<Left>'
      end, { expr = true, buffer = true })

      vim.keymap.set('i', '"', function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1
        col = col - 1
        local parser = vim.treesitter.get_parser(0, 'rholang')
        local tree = parser:parse()[1]
        local node = tree:root():named_descendant_for_range(row, col, row, col)
        local start_row, start_col, end_row, end_col = node:range()
        local cursor_pos = vim.api.nvim_buf_get_offset(0, row) + col
        local open_pos = vim.api.nvim_buf_get_offset(0, start_row) + start_col
        local close_pos = vim.api.nvim_buf_get_offset(0, end_row) + end_col
        local node_type = node:type()
        if node_type == "string_literal" then
          if cursor_pos + 1 < close_pos - 1 then
            return '\\"'
          else
            return '<Right>'
          end
        elseif node_type == "ERROR" then
          -- An escaped string yields an ERROR node
          return '"'
        else
          return '""<Left>'
        end
      end, { expr = true, buffer = true })

      -- Keymaps for skipping closing delimiters
      vim.keymap.set('i', '}', function()
        return skip_if_next_char_is('}')
      end, { expr = true, buffer = true })

      vim.keymap.set('i', ')', function()
        return skip_if_next_char_is(')')
      end, { expr = true, buffer = true })

      vim.keymap.set('i', ']', function()
        return skip_if_next_char_is(']')
      end, { expr = true, buffer = true })

      -- Keymap for backspace to handle delimiter deletion
      vim.keymap.set('i', '<BS>', function()
        return handle_delete(false, true)
      end, { expr = true, buffer = true })

      -- Keymap for delete to handle delimiter deletion
      vim.keymap.set('i', '<Del>', function()
        return handle_delete(true, true)
      end, { expr = true, buffer = true })

      -- Keymap for x to handle delimiter deletion in normal mode
      vim.keymap.set('n', 'x', function()
        return handle_delete(true, false)
      end, { expr = true, buffer = true })

      -- Keymap for X to handle delimiter deletion in normal mode
      vim.keymap.set('n', 'X', function()
        return handle_delete(false, false)
      end, { expr = true, buffer = true })

      -- Keymap for <CR> to handle indentation
      vim.keymap.set('i', '<CR>', function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        handle_return(row - 1, col)
        return ''
      end, { expr = true, buffer = true })

      -- Keymap for 'o' in normal mode
      vim.keymap.set('n', 'o', function()
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1 -- 0-based
        local current_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ''
        local col = #current_line
        handle_return(row, col)
        return ''
      end, { expr = true, buffer = true })

      -- Keymap for 'O' in normal mode
      vim.keymap.set('n', 'O', function()
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1 -- 0-based
        if row < 0 then
          handle_return(0, 0)
          return ''
        end
        local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
        local col = #prev_line
        handle_return(row - 1, col)
        return ''
      end, { expr = true, buffer = true })

      -- LSP configuration
      if config.lsp.enable then
        local root_dir = vim.fs.dirname(
          vim.fs.find({ '.git', 'rholang.toml' }, { upward = true })[1] or '.'
        )
        local lsp_cmd = {
          config.lsp.language_server_path,
          '--no-color',
          '--stdio',
          '--log-level', config.lsp.log_level,
          '--client-process-id', tostring(vim.fn.getpid()),
        }
        local client_id = vim.lsp.start({
          name = 'rholang',
          cmd = lsp_cmd,
          root_dir = root_dir,
          on_error = function(err)
            vim.notify('LSP error: ' .. vim.inspect(err), vim.log.levels.ERROR)
          end,
        })
        if client_id then
          vim.notify('LSP client for rholang-language-server started with ID: ' .. client_id, vim.log.levels.DEBUG)
        else
          vim.notify('Failed to start rholang-language-server', vim.log.levels.ERROR)
        end
      end
    end,
  })
end

-- Expose default_config for health checks
M.default_config = default_config

return M
