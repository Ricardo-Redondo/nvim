-- Python linting (flake8 + mypy) and formatting (isort + black, with <Leader>lf)

local line_length = 79 -- PEP 8; used by flake8, black and isort

-- flake8/mypy stay off until toggled with <Leader>uP (resets when nvim restarts)
local linters = { "flake8", "mypy" }
local function linters_enabled() return vim.g.python_linters == true end

local function toggle_linters()
  vim.g.python_linters = not linters_enabled()
  local lint = require "lint"
  if linters_enabled() then
    lint.try_lint()
  else
    for _, name in ipairs(linters) do
      vim.diagnostic.reset(lint.get_namespace(name))
    end
  end
  require("astrocore").notify(("Python linters %s"):format(linters_enabled() and "on" or "off"))
end

-- path to the project's uv `.venv` python for the current buffer, if there is one
local function venv_python()
  local venv = vim.fs.find(".venv", { path = vim.fn.expand "%:p:h", upward = true, type = "directory" })[1]
  local python = venv and venv .. "/bin/python"
  if python and vim.uv.fs_stat(python) then return python end
end

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "flake8", "mypy", "black", "isort" })
    end,
  },

  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = { ["<Leader>uP"] = { toggle_linters, desc = "Toggle Python linters (flake8, mypy)" } },
      },
    },
  },

  -- linters
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = linters
      opts.linters = opts.linters or {}

      -- same line length as black, and ignore checks black disagrees with
      local flake8_args = vim.deepcopy(require("lint.linters.flake8").args)
      table.insert(flake8_args, 1, "--max-line-length=" .. line_length)
      table.insert(flake8_args, 1, "--extend-ignore=E203,W503,E701")
      opts.linters.flake8 = { args = flake8_args, condition = linters_enabled }

      -- point mypy at the uv venv so it can see installed packages
      local mypy_args = vim.deepcopy(require("lint.linters.mypy").args)
      vim.list_extend(mypy_args, {
        "--python-executable",
        function() return venv_python() or vim.fn.exepath "python3" end,
      })
      opts.linters.mypy = { args = mypy_args, condition = linters_enabled }
    end,
  },

  -- formatters: isort sorts imports, then black formats
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "isort", "black" }
      opts.formatters = opts.formatters or {}
      opts.formatters.isort = { prepend_args = { "--profile", "black", "--line-length", tostring(line_length) } }
      opts.formatters.black = { prepend_args = { "--line-length", tostring(line_length) } }
    end,
  },

  -- ruff's linting/formatting would duplicate flake8/black, so turn its server off
  {
    "AstroNvim/astrolsp",
    opts = { handlers = { ruff = false } },
  },
}
