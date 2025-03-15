local M = {}

M.games = {}

function load_games()
  M.games.relative_jump = require("vim_games.games.relative_jump")
end

function load_core_commands()
  vim.api.nvim_create_user_command("VimGamesStop", function()
    for game_name, game_module in pairs(M.games) do
      if game_module.state and game_module.state.active then
        game_module.stop()
        print("Stopped " .. game_name .. " game.")
      end
    end
  end, {})

  vim.api.nvim_create_user_command("VimGamesList", function()
    print("Available Vim Games:")
    for game_name in pairs(M.games) do
      print("- " .. game_name:gsub("_", " "):gsub("^%l", string.upper))
    end
  end, {})
end

function register_commands()
  for _, game_module in pairs(M.games) do
    game_module.register_commands()
  end
end

function M.setup()
  load_games()
  load_core_commands()
  register_commands()
end

return M
