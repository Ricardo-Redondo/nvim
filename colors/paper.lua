-- "paper": a classic Vim look (plain text, mustard keywords, green types, red strings, blue
-- comments) in a light and a dark version. The dark one uses brighter shades of the same colors
-- so they stay readable on a dark page.
-- Switching the background (<Leader>ub or :ToggleTheme) reloads this file, which picks the version.

vim.cmd "hi clear" -- start from Neovim's built-in UI for this background (menus, diffs...)
if vim.fn.exists "syntax_on" == 1 then vim.cmd "syntax reset" end
vim.o.termguicolors = true
vim.g.colors_name = "paper"

local palettes = {
  light = {
    bg = "#ffffff",
    fg = "#1c1c1c",
    keyword = "#a67c00", -- while, if, return
    type = "#2e9a46", -- int, const, char, struct
    constant = "#c8323c", -- strings, numbers, stdout
    special = "#9b2fae", -- \n and other escapes
    comment = "#2b3fc7",
    preproc = "#8a3fb5", -- #include, #define
    linenr = "#5a5a5a",
    faint = "#b0b0b0",
    line = "#f2f2f2",
    select = "#cfe0f7",
    paren = "#e4e4e4",
    search = "#fff3a3",
    cursearch = "#ffd24d",
    hint = "#8a8a8a",
    bracket = "#707070", -- () {} [], softer than the text
    named = "#00808a", -- ALL_CAPS constants like BUFFER_SIZE
  },
  dark = {
    bg = "#1c1c1c",
    fg = "#dcdcdc",
    keyword = "#d7af3f",
    type = "#5fc977",
    constant = "#ef6b73",
    special = "#c77ddb",
    comment = "#7b8cf0",
    preproc = "#b98ae0",
    linenr = "#8a8a8a",
    faint = "#5a5a5a",
    line = "#262626",
    select = "#2f4466",
    paren = "#3a3a3a",
    search = "#5c4d12",
    cursearch = "#8a6d00",
    hint = "#7a7a7a",
    bracket = "#a0a0a0",
    named = "#4fc4c4",
  },
}
local c = palettes[vim.o.background] or palettes.light

local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

-- dark mode has no background of its own, so kitty's transparent, blurred one shows
-- through; light mode stays solid white (text would be hard to read on the blur)
local transparent = vim.o.background == "dark"

-- editor
hl("Normal", { fg = c.fg, bg = not transparent and c.bg or nil })
hl("NormalNC", { link = "Normal" })
hl("LineNr", { fg = c.linenr })
hl("CursorLineNr", { fg = c.fg, bold = true })
hl("CursorLine", { bg = c.line })
hl("Cursor", { fg = c.bg, bg = c.fg }) -- the text color, so it always shows against the page
hl("ColorColumn", { bg = c.line })
hl("Visual", { bg = c.select })
hl("NonText", { fg = c.faint })
hl("Whitespace", { fg = c.faint })
hl("EndOfBuffer", { fg = c.bg })
hl("MatchParen", { bg = c.paren, bold = true })
hl("Search", { bg = c.search })
hl("CurSearch", { bg = c.cursearch })
hl("IncSearch", { link = "CurSearch" })
hl("ModeMsg", { fg = c.fg, bold = true }) -- -- INSERT --

-- syntax
hl("Comment", { fg = c.comment })
hl("Constant", { fg = c.constant })
hl("String", { link = "Constant" })
hl("Character", { link = "Constant" })
hl("Number", { link = "Constant" })
hl("Boolean", { link = "Constant" })
hl("Float", { link = "Constant" })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.fg })
hl("Statement", { fg = c.keyword })
hl("Operator", { fg = c.fg })
hl("PreProc", { fg = c.preproc })
hl("Type", { fg = c.type })
hl("Special", { fg = c.special })
hl("Delimiter", { fg = c.fg })
hl("Todo", { fg = c.comment, bold = true })

-- treesitter (most groups fall back to the ones above; these differ in Neovim's defaults)
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.constant }) -- stdout, self, this
hl("@constant", { fg = c.named }) -- ALL_CAPS names like BUFFER_SIZE (set to c.fg for plain text)
hl("@constant.builtin", { fg = c.constant })
hl("@constant.macro", { fg = c.named }) -- the name in #define BUFFER_SIZE 1024
hl("@string.escape", { fg = c.special })
hl("@function", { fg = c.fg })
hl("@function.builtin", { fg = c.fg })
hl("@function.macro", { fg = c.fg })
hl("@constructor", { fg = c.fg })
hl("@property", { fg = c.fg })
hl("@module", { fg = c.fg })
hl("@punctuation", { fg = c.fg })
hl("@punctuation.bracket", { fg = c.bracket })
hl("@keyword", { fg = c.keyword })
hl("@keyword.type", { fg = c.type }) -- struct, enum
hl("@keyword.modifier", { fg = c.type }) -- const, static
hl("@keyword.directive", { fg = c.preproc })
hl("@keyword.import", { fg = c.preproc })
hl("@type.builtin", { fg = c.type })
hl("@type", { fg = c.type })
hl("@tag", { fg = c.keyword })
hl("@tag.attribute", { fg = c.type })
hl("@markup.heading", { fg = c.keyword, bold = true })
hl("@markup.link", { fg = c.comment, underline = true })

-- LSP: don't let semantic tokens repaint names that should stay black
hl("@lsp.type.variable", {})
hl("@lsp.type.parameter", {})
hl("@lsp.type.property", {})
hl("@lsp.type.function", {})
hl("@lsp.type.method", {})
hl("@lsp.type.macro", {})
hl("@lsp.mod.readonly", {})
hl("@lsp.type.comment", {}) -- clangd greys out #if 0 blocks with this; keep comments blue

-- diagnostics
hl("DiagnosticError", { fg = c.constant })
hl("DiagnosticWarn", { fg = c.keyword })
hl("DiagnosticInfo", { fg = c.comment })
hl("DiagnosticHint", { fg = c.type })
hl("DiagnosticUnderlineError", { sp = c.constant, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.keyword, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.comment, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.type, undercurl = true })

-- git
hl("Added", { fg = c.type })
hl("Changed", { fg = c.keyword })
hl("Removed", { fg = c.constant })
hl("GitSignsCurrentLineBlame", { fg = c.faint, italic = true })

-- completion ghost text and inline hints
hl("BlinkCmpGhostText", { fg = c.faint })
hl("LspInlayHint", { fg = c.hint, bg = c.line })
