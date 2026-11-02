-- Extra plugins and overrides of AstroNvim defaults

-- true when the cursor is inside a string literal but NOT inside an f-string `{...}`
-- (or a JS template `${...}`), where completion should stay quiet
local function in_plain_string()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 1, 0) } })
  if not ok then return false end
  while node do
    local type = node:type()
    if type == "interpolation" or type == "template_substitution" then return false end
    if type:find "string" and not type:find "^string_[se]" then return true end
    node = node:parent()
  end
  return false
end

-- lets the file picker search anywhere: `~/dir/name` or `/dir/name` searches for `name` in that
-- folder instead of the project, and clearing it goes back to the project
local function search_typed_path(picker, filter)
  picker.project_cwd = picker.project_cwd or picker:cwd()
  local dir, rest = filter.pattern:match "^(~?/.-)([^/]*)$"
  dir = dir and vim.fs.normalize(dir)
  if dir and vim.fn.isdirectory(dir) == 1 then
    filter.pattern = rest
  else
    dir = picker.project_cwd
  end
  if dir ~= picker:cwd() then
    picker:set_cwd(dir)
    filter:set_cwd(dir)
    return true
  end
end

---@type LazySpec
return {
  -- Oil: edit the filesystem like a buffer (open with `-` or <Leader>O)
  {
    "stevearc/oil.nvim",
    lazy = false, -- so `nvim .` opens Oil instead of neo-tree
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      keymaps = {
        ["q"] = "actions.close",
      },
    },
  },
  -- Let Oil handle directories instead of neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        hijack_netrw_behavior = "disabled",
        window = { mappings = { ["<C-h>"] = "toggle_hidden" } },
      },
      event_handlers = {
        -- close the sidebar after opening a file from it
        {
          event = "file_open_requested",
          handler = function() require("neo-tree.command").execute { action = "close" } end,
        },
      },
    },
  },

  -- Autopairs: AstroNvim only enables it in listed buffers, but neo-tree lists a file after
  -- opening it, which left autopairs off in files opened from the sidebar
  {
    "windwp/nvim-autopairs",
    opts = {
      enabled = function(bufnr) return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" end,
    },
  },

  -- Discord rich presence: plain Neovim branding, and no buttons as the default one
  -- publishes the git remote URL. Discord drops updates when rate limited instead of
  -- queueing them, so sync resends the current one to stop the status getting stuck
  {
    "vyfor/cord.nvim",
    opts = function(_, opts)
      opts.editor = { client = "neovim", tooltip = "Neovim" }
      opts.buttons = nil
      opts.advanced = { discord = { sync = { enabled = true, mode = "periodic", interval = 12000, pad = true } } }
    end,
  },

  -- Git signs: show inline blame like GitLens
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
    },
  },

  -- Completion: VSCode-like behavior (Tab/Enter accept, docs + signature popups, ghost text)
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        -- Tab accepts the highlighted suggestion (like VSCode); Up/Down or C-j/C-k to pick another
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        -- no automatic suggestions inside plain strings (<C-Space> still opens them manually)
        menu = { auto_show = function(ctx) return ctx.mode ~= "cmdline" and not in_plain_string() end },
        ghost_text = { enabled = function() return not in_plain_string() end },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true },
    },
  },

  -- Snacks: dashboard header + extras
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { filter = { transform = search_typed_path } },
        },
      },
      styles = {
        input = {
          -- floating prompts can't be focused again once you leave them, so close them instead of
          -- leaving them stuck. Not the cancel action, as that moves the cursor back to where it was
          on_win = function(win)
            win:on("WinLeave", function()
              vim.schedule(function()
                if win:valid() then win:close() end
              end)
            end, { buf = true })
          end,
        },
      },
      dashboard = {
        preset = {
          header = table.concat({
            "███    ██ ███████  ██████  ██    ██ ██ ███    ███",
            "████   ██ ██      ██    ██ ██    ██ ██ ████  ████",
            "██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██",
            "██   ████ ███████  ██████    ████   ██ ██      ██",
          }, "\n"),
        },
      },
    },
  },
}
