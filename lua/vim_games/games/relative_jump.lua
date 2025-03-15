local M = {}

local num_lines = 30
local target_char = "x"
local initial_cursor_position = 1

M.name = "relative_jump"

function M.start()
  if M.state.active then
    open_buffer(M.state.buffer)
  end

  M.state.active = true
  initialize_game()
end

function M.stop()
  if not M.state.active then
    print("Relative Jump Game is not active.")
    return
  end

  delete(M.state.buffer)
  cleanup_state()
end

function M.register_commands()
  vim.api.nvim_create_user_command("VimGamesRelativeJump", function()
    M.start()
  end, {})
end

function open_buffer(buffer)
  if buffer and vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_set_current_buf(buffer)
  else
    print("Buffer is nil")
  end
end

function initialize_game()
  create_buffer()
  write_lines_into(M.state.buffer)
  set_cursor_at_line(initial_cursor_position)
  set_target_at_random_line(initial_cursor_position)
  register_events_into(M.state.buffer)
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
  local lines = {}
  for _ = 1, num_lines do
    table.insert(lines, "")
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
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

function is_game_over()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1]

  if is_cursor_on_target_line(current_line) then
    clear_target_at_line(M.state.target_line)
    set_target_at_random_line(current_line)
  end
end

function is_cursor_on_target_line(current_line)
  return current_line == M.state.target_line
end

function clear_target_at_line(line)
  set_char_at_line(line, "")
end

function set_target_at_random_line(cursor_line)
  M.state.target_line = generate_target_line(cursor_line)
  set_char_at_line(M.state.target_line, target_char)
end

function generate_target_line(cursor_line)
  math.randomseed(os.time())

  local top_area_length = cursor_line
  local bottom_area_length = num_lines - cursor_line

  local start = (top_area_length >= bottom_area_length) and 1 or (cursor_line + 1)
  local finish = (top_area_length >= bottom_area_length) and (cursor_line - 1) or num_lines
  
  return math.random(start, finish)
end

function set_char_at_line(line, char)
  vim.api.nvim_buf_set_lines(M.state.buffer, line - 1, line, false, {char})
end

function delete(buffer)
  if buffer and vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_buf_delete(buffer, { force = true })
  end
end

function cleanup_state()
  M.state.active = false
  M.state.buffer = nil
  M.state.target_line = nil

  if M.state.cursor_autocmd_id then
    pcall(vim.api.nvim_del_autocmd, M.state.cursor_autocmd_id)
    M.state.cursor_autocmd_id = nil
  end

  if M.state.mode_autocmd_id then
    pcall(vim.api.nvim_del_autocmd, M.state.mode_autocmd_id)
    M.state.mode_autocmd_id = nil
  end
end

M.state = {
  active = false,
  buffer = nil,
  cursor_autocmd_id = nil,
  mode_autocmd_id = nil,
  target_line = nil,
}

return M
