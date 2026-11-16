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

-- every header the file already gets, directly or through the project's own headers (like
-- minishell.h including <stdio.h>). clangd only looks at the file's own #include lines, so it
-- would add <stdio.h> again
local function included_headers(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(bufnr, { "compile_flags.txt", "compile_commands.json", "Makefile", ".git" })
    or vim.fs.dirname(file)
  local found, visited = {}, {}

  -- a project header named in `#include "name.h"`: next to the file first, then anywhere in the project
  local function locate(name, from_dir)
    local near = vim.fs.joinpath(from_dir, name)
    if vim.uv.fs_stat(near) then return near end
    return vim.fs.find(vim.fs.basename(name), { path = root, type = "file", limit = 1 })[1]
  end

  local function scan(lines, dir, depth)
    for _, line in ipairs(lines) do
      local quote, name = line:match '^%s*#%s*include%s*([<"])([^>"]+)[>"]'
      if name then
        found[name] = true
        local path = quote == '"' and depth < 5 and locate(name, dir)
        if path and not visited[path] then
          visited[path] = true
          local ok, header_lines = pcall(vim.fn.readfile, path)
          if ok then scan(header_lines, vim.fs.dirname(path), depth + 1) end
        end
      end
    end
  end

  scan(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), vim.fs.dirname(file), 0)
  return found
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
  -- picking a completion adds the #include it needs, unless your own header already includes it
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          lsp = {
            transform_items = function(_, items)
              if vim.bo.filetype ~= "c" and vim.bo.filetype ~= "cpp" then return items end
              local included = included_headers(0)
              for _, item in ipairs(items) do
                if item.additionalTextEdits then
                  item.additionalTextEdits = vim.tbl_filter(function(edit)
                    local header = edit.newText:match '^%s*#%s*include%s*[<"]([^>"]+)[>"]'
                    return not (header and included[header])
                  end, item.additionalTextEdits)
                end
              end
              return items
            end,
          },
        },
      },
    },
  },

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
