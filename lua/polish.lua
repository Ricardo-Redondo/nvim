-- This will run last in the setup process.

-- Highlight yanked text briefly (like VSCode selection flash)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank { timeout = 150 } end,
})

-- Open a terminal in a split, ready to type
local function open_terminal(split)
  return function()
    vim.cmd(split)
    vim.cmd.terminal()
    vim.cmd.startinsert()
  end
end
vim.api.nvim_create_user_command("Tsplit", open_terminal "split", {})
vim.api.nvim_create_user_command("Tvsplit", open_terminal "vsplit", {})

-- User commands must start with a capital, so let the lowercase names expand to them
vim.cmd [[
  cnoreabbrev <expr> tsplit getcmdtype() == ':' && getcmdline() == 'tsplit' ? 'Tsplit' : 'tsplit'
  cnoreabbrev <expr> tvsplit getcmdtype() == ':' && getcmdline() == 'tvsplit' ? 'Tvsplit' : 'tvsplit'
]]

-- Suggestions requested before the language server attached stay empty for the whole word,
-- so ask again once it's ready (clangd needs a moment after attaching to read the headers)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.defer_fn(function()
      if args.buf ~= vim.api.nvim_get_current_buf() or vim.fn.mode() ~= "i" then return end
      local trigger = require "blink.cmp.completion.trigger"
      if not trigger.context then return end
      -- not cmp.show(), which would ignore the auto_show rule for strings
      trigger.hide()
      vim.schedule(function() trigger.show { trigger_kind = "keyword" } end)
    end, 700)
  end,
})
