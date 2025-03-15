local M = {}

M.name = "find"

function M.start()
  if M.state.active then
  end

  M.state.active = true
  initialize_game()
end

function M.stop()
  if not M.state.active then
    print("Find Game is not active.")
    return
  end

  delete(M.state.buffer)
  cleanup_state()
end

function M.register_commands()
  vim.api.nvim_create_user_command("VimGamesFind", function()
    M.start()
  end, {})
end

function initialize_game()
  create_buffer()
  write_lines_into(M.state.buffer)
  set_cursor_at_line(initial_cursor_position)
end

function create_buffer()
  M.state.buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(M.state.buffer)

  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'x', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'X', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'd', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'D', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'dd', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'r', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'c', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'C', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 's', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'S', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'o', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'O', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'p', '', { noremap = true })
  vim.api.nvim_buf_set_keymap(M.state.buffer, 'n', 'P', '', { noremap = true })
end

function write_lines_into(buffer)
  local content = read_file("resources/array_max_finder")
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, content)
end

function read_file(filename)
  local file = io.open(filename, "r")
  if not file then
    print("Error: Cannot open file '" .. filename .. "'")
    return false
  end

  -- Read file content
  local content = file:read("*all")
  file:close()
  return content
end

function set_cursor_at_line(line)
  vim.api.nvim_win_set_cursor(0, {line, 0})
end

function register_events_into(buffer)
  M.state.cursor_autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buffer,
    callback = function()
      is_game_over()
    end,
  })

  M.state.mode_autocmd_id = vim.api.nvim_create_autocmd("ModeChanged", {
    buffer = buffer,
    callback = function()
      local current_mode = vim.api.nvim_get_mode().mode
      if current_mode:match("^[iRsvS\x16]") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)
      end
    end,
  })
end

M.state = {
  active = false,
  buffer = nil,
  cursor_autocmd_id = nil,
  mode_autocmd_id = nil,
  target_line = nil,
}

return M
