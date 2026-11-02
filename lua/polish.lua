-- This will run last in the setup process.

-- Highlight yanked text briefly (like VSCode selection flash)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank { timeout = 150 } end,
})

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
