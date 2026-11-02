-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- == Language packs (LSP + formatter + linter + treesitter per language) ==
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.typescript" }, -- needs nodejs/npm
  { import = "astrocommunity.pack.html-css" }, -- needs nodejs/npm
  { import = "astrocommunity.pack.json" }, -- needs nodejs/npm
  { import = "astrocommunity.pack.yaml" }, -- needs nodejs/npm
  { import = "astrocommunity.pack.bash" }, -- needs nodejs/npm
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.cpp" }, -- clangd, clangd_extensions, cmake-tools, codelldb debugger
  { import = "astrocommunity.pack.cmake" }, -- CMakeLists.txt LSP

  -- == Linting / formatting engines (per-language tools set in lua/plugins/python.lua etc.) ==
  { import = "astrocommunity.lsp.nvim-lint" },
  { import = "astrocommunity.editing-support.conform-nvim" },

  -- == File explorer ==
  { import = "astrocommunity.file-explorer.oil-nvim" },

  -- == Git ==
  { import = "astrocommunity.git.diffview-nvim" }, -- VSCode-style diff / file history view
  { import = "astrocommunity.git.neogit" }, -- Magit-like git UI (stage, commit, push...)

  -- == VSCode-like editing ==
  { import = "astrocommunity.editing-support.vim-visual-multi" }, -- multi-cursor (<C-n> like Ctrl+D)
  { import = "astrocommunity.editing-support.nvim-treesitter-context" }, -- sticky scroll
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" }, -- bracket pair colorization
  { import = "astrocommunity.motion.nvim-surround" }, -- add/change/delete surrounding quotes/brackets
  { import = "astrocommunity.recipes.heirline-vscode-winbar" }, -- breadcrumbs bar
  { import = "astrocommunity.diagnostics.trouble-nvim" }, -- "Problems" panel
  { import = "astrocommunity.search.grug-far-nvim" }, -- project-wide search & replace
  { import = "astrocommunity.scrolling.satellite-nvim" }, -- scrollbar with git/diagnostic marks
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" }, -- update imports when renaming files

  -- == Live preview and Discord ==
  { import = "astrocommunity.utility.live-preview" }, -- like VSCode's Live Server, for HTML and Markdown
  { import = "astrocommunity.media.cord-nvim" }, -- Discord rich presence

  -- == AI inline suggestions (GitHub Copilot ghost text) ==
  -- Uncomment if you have Copilot access (needs nodejs), then run :Copilot auth
  -- { import = "astrocommunity.completion.copilot-lua-cmp" },

  -- == Colorscheme ==
  { import = "astrocommunity.colorscheme.vscode-nvim" },
}
