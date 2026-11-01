# Neovim config

My IDE-style Neovim setup, built on [AstroNvim](https://astronvim.com). It has autocomplete,
LSP, git tools, the [Oil](https://github.com/stevearc/oil.nvim) file manager and debugging.

## Install

The script installs the system packages, this config and all plugins. It's safe
to run again, and an existing config from somewhere else is moved to `nvim.bak-<date>`, not deleted.

### Linux (Arch, CachyOS, Debian, Ubuntu, Fedora)

```sh
curl -fsSL https://raw.githubusercontent.com/Ricardo-Redondo/nvim/main/install.sh | bash
```

Needs Neovim 0.11 or newer. Debian and Ubuntu often ship an older one, in which case the script
warns you and skips plugins. Install a newer Neovim and open it once to finish.

### macOS

Install [Homebrew](https://brew.sh) and the Xcode command line tools first, then:

```sh
xcode-select --install
curl -fsSL https://raw.githubusercontent.com/Ricardo-Redondo/nvim/main/install.sh | bash
```

Alt shortcuts need your terminal to send Option as Alt. In kitty, add `macos_option_as_alt yes`
to `kitty.conf`.

### Nix

Packages go into your Nix profile. On NixOS this is automatic. Anywhere else, use:

```sh
curl -fsSL https://raw.githubusercontent.com/Ricardo-Redondo/nvim/main/install.sh | NVIM_USE_NIX=1 bash
```

On NixOS you also need this in your system config, because Mason downloads prebuilt binaries
that NixOS can't otherwise run:

```nix
programs.nix-ld.enable = true;
```

### Without sudo

Neovim, git and curl must already be installed:

```sh
curl -fsSL https://raw.githubusercontent.com/Ricardo-Redondo/nvim/main/install.sh | NVIM_SKIP_PACKAGES=1 bash
```

### After installing

1. Run `nvim`.
2. Mason installs the language servers in the background, about 1.6 GB. Check progress with `:Mason`.

## Update and uninstall

Update by running the install command again, or `git pull` in `~/.config/nvim`.

Uninstall:

```sh
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

## Shortcuts

`<Space>` is the leader key. Press it and wait to see every available command.

These are the shortcuts this config adds.

### Files and search

| Key | Action |
| --- | --- |
| `Ctrl+S` | Save (also leaves insert mode) |
| `Ctrl+P` | Find files |
| `Ctrl+Shift+F` | Search in project (use `<Space>fw` if your terminal doesn't pass it through) |
| `Ctrl+B` | Toggle the sidebar |
| `-` or `<Space>O` | Open Oil on the current folder (`q` closes it) |
| `<Space>n` | New file, asks for a name first and creates missing folders |

### Buffers

| Key | Action |
| --- | --- |
| `Shift+L` / `Shift+H` | Next / previous buffer |

### Editing

| Key | Action |
| --- | --- |
| `Alt+J` / `Alt+K` | Move the line or selection down / up |
| `<` / `>` in visual mode | Indent and keep the selection |
| `Ctrl+Backspace` or `Ctrl+H` | Delete the previous word (insert and command line) |
| `Ctrl+Delete` | Delete the next word |
| `Ctrl+N` | Multi-cursor, like Ctrl+D in VSCode |

### Autocomplete

| Key | Action |
| --- | --- |
| `Tab` | Accept the suggestion, or jump to the next snippet field |
| `Shift+Tab` | Jump to the previous snippet field |
| `↑` / `↓` or `Ctrl+J` / `Ctrl+K` | Choose another suggestion |
| `Ctrl+Space` | Open suggestions manually |

### Git

| Key | Action |
| --- | --- |
| `<Space>gn` | Neogit: stage and commit, like VSCode's Source Control |
| `<Space>gd` / `<Space>gD` | Open / close the Diffview diff |
| `<Space>gH` | History of the current file |
| `<Space>gB` | Toggle inline blame |

### Code

| Key | Action |
| --- | --- |
| `<Space>lf` | Format the file |
| `<Space>r` | Compile and run the current C/C++ file |
| `<Space>uP` | Toggle flake8 and mypy until restart |

### Useful AstroNvim defaults

| Key | Action |
| --- | --- |
| `<Space>ff` / `<Space>fw` | Find files / search text |
| `<Space>fb` / `<Space>fo` | Open buffers / recent files |
| `<Space>bb` | Pick a buffer by letter |
| `<Space>c` / `<Space>bc` | Close the buffer / all the others |
| `gd` | Go to definition |
| `<Space>lr` / `<Space>la` | Rename symbol / code action |
| `<Space>R` | Rename the current file |
| `<Space>ud` / `<Space>uv` | Toggle all diagnostics / inline messages |
| `<Space>uF` | Toggle format on save |
| `]g` / `[g` | Next / previous git change |
| `<Space>gs` / `<Space>gS` | Stage the change / whole file |
| `<Space>db` / `<Space>dc` | Set a breakpoint / start debugging |
| `F7` | Terminal |

## How it behaves

- **Formatting is manual.** Nothing formats on save. Press `<Space>lf`.
- **Python** formats with isort and black at 79 columns. flake8 and mypy are off until `<Space>uP`.
  basedpyright does completion and navigation, not type checking.
- **C and C++** use 4 spaces and `clang-format`. A project's `.clang-format` takes priority.
- **`.h` files** count as C unless they contain C++ such as `class` or `std::`.
- **Suggestions** stay hidden inside strings, except inside f-string braces.
  `Ctrl+Space` still opens them.
- **The mouse is off** so a touchpad can't move the cursor. `:set mouse=a` turns it on until restart.
- **Arrow keys** wrap across lines.

## Project setup

### C and C++

clangd needs to know your include paths, or it reports false errors about missing headers.

- **Makefile:** run `make clean && bear -- make` once, and again after adding files.
- **CMake:** `:CMakeGenerate` handles it.
- **Plain `gcc`:** add a `compile_flags.txt` to the project root, with one flag per line such as `-Iinclude`.

Then run `:lsp restart`.

### Python

Projects made with `uv init` work with no setup: `.venv` is found from any subfolder. After
`uv add`, run `:lsp restart`.

## Language packs

Each language is one line in `lua/community.lua`. A pack sets up that language's server,
formatter, linter and syntax highlighting. These are enabled:

Lua, Python, TypeScript, HTML/CSS, JSON, YAML, Bash, Markdown, TOML, C/C++ and CMake.

They're all optional, and most of the 1.6 GB download comes from them, so remove what you don't use.

### Remove a language

1. Delete its line from `lua/community.lua`:

   ```lua
   { import = "astrocommunity.pack.typescript" },
   ```

2. Restart `nvim` and run `:Lazy clean` to delete its plugins.
3. Open `:Mason` and press `X` on its tools to uninstall them. They aren't removed automatically.

### Add a language

1. Find the name in the [list of packs](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack).
2. Add a line to `lua/community.lua`:

   ```lua
   { import = "astrocommunity.pack.rust" },
   ```

3. Restart `nvim`. Its plugins and tools install themselves.

## Layout

| File | Purpose |
| --- | --- |
| `install.sh` | Installer |
| `lua/community.lua` | Language packs and community plugins |
| `lua/plugins/astrocore.lua` | Shortcuts and editor options |
| `lua/plugins/astrolsp.lua` | Language server settings |
| `lua/plugins/user.lua` | Plugin tweaks |
| `lua/plugins/python.lua` | Python linters and formatters |
| `lua/plugins/c.lua` | C and C++ indentation and formatters |

Any other file you add to `lua/plugins/` is loaded automatically, and the folders listed in
`.gitignore` stay out of the repo. That's useful for personal or machine-specific settings.

## License

[GPLv3](LICENSE), the same license as [AstroNvim](https://github.com/AstroNvim/AstroNvim).
Based on the [AstroNvim template](https://github.com/AstroNvim/template).
