-- C and C++ use 4 spaces and clang-format
-- Another file in lua/plugins/ can change C: set vim.g.c_use_tabs, or its formatter in conform

local cpp_patterns = {
  "^%s*class%s",
  "^%s*namespace%s",
  "^%s*template%s*<",
  "^%s*public:",
  "^%s*private:",
  "std::",
  "#%s*include%s*<iostream>",
}

-- nvim treats every `.h` as C++, so only do that if the header actually contains C++
local function header_filetype(_, bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
    for _, pattern in ipairs(cpp_patterns) do
      if line:find(pattern) then return "cpp" end
    end
  end
  return "c"
end

local function set_indent(buf, use_tabs)
  local bo = vim.bo[buf]
  bo.expandtab = not use_tabs
  bo.tabstop = 4
  bo.softtabstop = 4
  bo.shiftwidth = 4
end

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = {
      filetypes = { extension = { h = header_filetype } },
      autocmds = {
        c_indent = {
          {
            event = "FileType",
            pattern = "c",
            desc = "Indent C with 4 spaces, or tabs if vim.g.c_use_tabs is set",
            callback = function(args) set_indent(args.buf, vim.g.c_use_tabs == true) end,
          },
          {
            event = "FileType",
            pattern = "cpp",
            desc = "Indent C++ with 4 spaces",
            callback = function(args) set_indent(args.buf, false) end,
          },
        },
      },
    },
  },

  -- don't let existing files override the indentation above
  {
    "NMAC427/guess-indent.nvim",
    opts = { filetype_exclude = { "netrw", "tutor", "c", "cpp" } },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = opts.formatters_by_ft.c or { "clang-format" }
      opts.formatters_by_ft.cpp = { "clang-format" }
      opts.formatters = opts.formatters or {}
      opts.formatters["clang-format"] = {
        -- 4 spaces unless the project has its own .clang-format
        prepend_args = function(_, ctx)
          if vim.fs.root(ctx.dirname, { ".clang-format", "_clang-format" }) then return {} end
          return { "--style={BasedOnStyle: LLVM, IndentWidth: 4}" }
        end,
      }
    end,
  },
}
