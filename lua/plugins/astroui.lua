-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

-- Light/dark mode: <Leader>ub or :ToggleTheme switches, and the choice is remembered on restart.
-- Both modes use the classic Vim look in colors/paper.lua.
local theme_file = vim.fn.stdpath "state" .. "/background"
local saved = vim.fn.filereadable(theme_file) == 1 and vim.fn.readfile(theme_file)[1]
if saved == "light" or saved == "dark" then vim.o.background = saved end

local function save_background() pcall(vim.fn.writefile, { vim.o.background }, theme_file) end
vim.api.nvim_create_autocmd("OptionSet", { pattern = "background", callback = save_background })
vim.api.nvim_create_user_command("ToggleTheme", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
  save_background()
end, { bar = true, desc = "Switch between light and dark mode" })

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "paper", -- colors/paper.lua, light and dark
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
