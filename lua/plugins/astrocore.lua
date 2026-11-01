-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true, -- auto close brackets/quotes
      cmp = true, -- autocompletion
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      g = {
        autoformat = false, -- no format on save; format manually with <Leader>lf (toggle with <Leader>uF)
      },
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        scrolloff = 8,
        mouse = "", -- no mouse, so brushing the touchpad can't move the cursor
        clipboard = "unnamedplus", -- share system clipboard
        undofile = true, -- persistent undo
        confirm = true,
        whichwrap = "b,s,<,>,[,]", -- arrow keys wrap across lines (normal and insert mode)
      },
    },
    mappings = {
      n = {
        -- VSCode-like shortcuts
        ["<C-s>"] = { "<Cmd>silent! update<CR>", desc = "Save file" },
        ["<C-p>"] = { function() require("snacks").picker.files() end, desc = "Find files" },
        ["<C-S-f>"] = { function() require("snacks").picker.grep() end, desc = "Search in project" },
        ["<C-b>"] = { "<Cmd>Neotree toggle<CR>", desc = "Toggle sidebar explorer" },
        ["-"] = { "<Cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
        -- the line() checks stop these at the buffer edges, where `:m` errors with E16
        ["<A-j>"] = { "<Cmd>if line('.') < line('$') | m .+1 | exe 'normal! ==' | endif<CR>", desc = "Move line down" },
        ["<A-k>"] = { "<Cmd>if line('.') > 1 | m .-2 | exe 'normal! ==' | endif<CR>", desc = "Move line up" },

        -- buffer navigation (tabs)
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<S-l>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-h>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- new file: ask for a name first (also used by the dashboard "New File" button)
        ["<Leader>n"] = {
          function()
            vim.ui.input({ prompt = "New file name: ", completion = "file" }, function(name)
              if name == nil then return end -- cancelled
              if name == "" then return vim.cmd.enew() end -- no name: unnamed buffer like before
              local path = vim.fn.fnamemodify(vim.fn.expand(name), ":p")
              vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p") -- create missing folders
              vim.cmd.edit(vim.fn.fnameescape(path))
            end)
          end,
          desc = "New file",
        },

        -- compile & run current C/C++ file in a terminal (single-file programs)
        ["<Leader>r"] = {
          function()
            local ft = vim.bo.filetype
            if ft ~= "c" and ft ~= "cpp" then return vim.notify("Run: only C/C++ supported", vim.log.levels.WARN) end
            vim.cmd "silent! update"
            local file = vim.fn.shellescape(vim.fn.expand "%:p")
            local out = vim.fn.shellescape(vim.fn.expand "%:p:r")
            local cc = ft == "c" and "gcc -std=c17" or "g++ -std=c++23"
            local cmd = ("%s -Wall -Wextra -g %s -o %s && %s"):format(cc, file, out, out)
            require("toggleterm").exec(cmd, nil, nil, nil, "horizontal")
          end,
          desc = "Compile & run file",
        },

        -- git (Neogit instead of the lazygit terminals AstroNvim adds)
        ["<Leader>gg"] = false,
        ["<Leader>tl"] = false,
        ["<Leader>gd"] = { "<Cmd>DiffviewOpen<CR>", desc = "Diff view (working tree)" },
        ["<Leader>gD"] = { "<Cmd>DiffviewClose<CR>", desc = "Close diff view" },
        ["<Leader>gH"] = { "<Cmd>DiffviewFileHistory %<CR>", desc = "File history" },
        ["<Leader>gn"] = { "<Cmd>Neogit<CR>", desc = "Neogit" },
        ["<Leader>gB"] = {
          function() require("gitsigns").toggle_current_line_blame() end,
          desc = "Toggle inline git blame",
        },
      },
      i = {
        -- Ctrl+Backspace deletes the previous word (terminals send it as <C-h> or <C-BS>)
        ["<C-BS>"] = { "<C-w>", desc = "Delete previous word" },
        ["<C-h>"] = { "<C-w>", desc = "Delete previous word" },
        ["<C-Del>"] = { "<C-o>dw", desc = "Delete next word" },
        ["<C-s>"] = { "<Esc><Cmd>silent! update<CR>", desc = "Save file" },
        ["<A-j>"] = { "<Esc><Cmd>if line('.') < line('$') | m .+1 | exe 'normal! ==' | endif<CR>gi", desc = "Move line down" },
        ["<A-k>"] = { "<Esc><Cmd>if line('.') > 1 | m .-2 | exe 'normal! ==' | endif<CR>gi", desc = "Move line up" },
      },
      c = {
        ["<C-BS>"] = { "<C-w>", desc = "Delete previous word" },
        ["<C-h>"] = { "<C-w>", desc = "Delete previous word" },
      },
      v = {
        ["<A-j>"] = {
          [[max([line('v'), line('.')]) < line('$') ? ":m '>+1<CR>gv=gv" : '']],
          expr = true,
          desc = "Move selection down",
        },
        ["<A-k>"] = {
          [[min([line('v'), line('.')]) > 1 ? ":m '<-2<CR>gv=gv" : '']],
          expr = true,
          desc = "Move selection up",
        },
        ["<"] = { "<gv", desc = "Unindent" },
        [">"] = { ">gv", desc = "Indent" },
      },
    },
  },
}
