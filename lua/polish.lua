-- This will run last in the setup process.

-- Highlight yanked text briefly (like VSCode selection flash)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank { timeout = 150 } end,
})
