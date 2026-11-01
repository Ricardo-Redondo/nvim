#!/usr/bin/env bash
# Installs this Neovim config and the tools it needs:
#
#   curl -fsSL https://raw.githubusercontent.com/Ricardo-Redondo/nvim/main/install.sh | bash
#
# Safe to run again: it updates the config instead of reinstalling it.
# An existing config that came from somewhere else is moved to nvim.bak-<date>, not deleted.
#
#   NVIM_SKIP_PACKAGES=1   skip system packages (no sudo, e.g. a school machine)
#   NVIM_USE_NIX=1         install packages with Nix (automatic on NixOS)
#   NVIM_REPO=<url>        clone from a different repo
set -euo pipefail

REPO="${NVIM_REPO:-https://github.com/Ricardo-Redondo/nvim.git}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

PACMAN_PACKAGES=(neovim git curl ripgrep fd gcc make unzip python nodejs npm clang gdb cmake bear)
APT_PACKAGES=(neovim git curl ripgrep fd-find build-essential unzip python3 python3-venv nodejs npm clang clangd clang-format gdb cmake bear)
DNF_PACKAGES=(neovim git curl ripgrep fd-find gcc make unzip python3 nodejs npm clang clang-tools-extra gdb cmake bear)
BREW_PACKAGES=(neovim git ripgrep fd python node clang-format cmake bear)
NIX_PACKAGES=(neovim git curl ripgrep fd gcc gnumake unzip python3 nodejs clang-tools cmake bear)

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$1" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$1" >&2
  exit 1
}

install_with_brew() {
  # a fresh Homebrew isn't on PATH until the shell is restarted
  if ! command -v brew >/dev/null; then
    local prefix
    for prefix in /opt/homebrew /usr/local; do
      if [ -x "$prefix/bin/brew" ]; then eval "$("$prefix/bin/brew" shellenv)"; fi
    done
  fi
  command -v brew >/dev/null || die "Homebrew isn't installed, get it from https://brew.sh and rerun this"

  info "Installing Homebrew packages"
  brew install "${BREW_PACKAGES[@]}" || warn "brew failed for some packages"
}

install_with_nix() {
  info "Installing Nix packages"
  nix --extra-experimental-features "nix-command flakes" \
    profile install "${NIX_PACKAGES[@]/#/nixpkgs#}" || warn "nix profile install failed"
  export PATH="$HOME/.nix-profile/bin:$PATH"

  # Mason downloads prebuilt binaries, which NixOS can't run on its own
  if [ -e /etc/NIXOS ] && [ -z "${NIX_LD:-}" ]; then
    warn "set programs.nix-ld.enable = true in your NixOS config, or language servers won't start"
  fi
}

has_system_manager() {
  command -v pacman >/dev/null || command -v apt-get >/dev/null || command -v dnf >/dev/null
}

install_packages() {
  if [ "${NVIM_SKIP_PACKAGES:-}" = "1" ]; then
    info "Skipping system packages"
    return
  fi

  # Nix doesn't need sudo, so also use it when it's the only package manager around
  if [ -e /etc/NIXOS ] || [ "${NVIM_USE_NIX:-}" = "1" ] || { ! has_system_manager && command -v nix >/dev/null; }; then
    install_with_nix
    return
  fi

  if [ "$(uname -s)" = "Darwin" ]; then
    install_with_brew
    return
  fi

  local sudo=""
  if [ "$(id -u)" -ne 0 ]; then
    if ! command -v sudo >/dev/null; then
      warn "no sudo here, skipping system packages"
      return
    fi
    sudo="sudo"
  fi

  info "Installing system packages"
  if command -v pacman >/dev/null; then
    $sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}" ||
      warn "pacman failed. If it was a 404, run 'sudo pacman -Syu' or 'sudo cachyos-rate-mirrors' and rerun this"
  elif command -v apt-get >/dev/null; then
    $sudo apt-get update || warn "apt-get update failed"
    $sudo apt-get install -y "${APT_PACKAGES[@]}" || warn "apt-get failed"
  elif command -v dnf >/dev/null; then
    $sudo dnf install -y "${DNF_PACKAGES[@]}" || warn "dnf failed"
  else
    warn "unknown package manager, install these yourself: ${PACMAN_PACKAGES[*]}"
  fi
}

# owner/name of a git URL, so SSH and HTTPS remotes of the same repo compare equal
repo_id() {
  printf '%s\n' "$1" | sed -E 's#\.git$##; s#/$##; s#^.*[:/]([^/:]+/[^/:]+)$#\1#'
}

install_config() {
  mkdir -p "$(dirname "$CONFIG")"

  if [ -d "$CONFIG/.git" ] &&
    [ "$(repo_id "$(git -C "$CONFIG" remote get-url origin 2>/dev/null)")" = "$(repo_id "$REPO")" ]; then
    info "Updating config in $CONFIG"
    # lazy.nvim rewrites this file on every machine, a local copy would block the pull
    git -C "$CONFIG" checkout -- lazy-lock.json 2>/dev/null || true
    git -C "$CONFIG" pull --ff-only || warn "couldn't update, keeping your local copy as it is"
    return
  fi

  # clone first, so a failed clone leaves any existing config where it was
  info "Cloning config to $CONFIG"
  local new="$CONFIG.new-$$"
  git clone "$REPO" "$new" || {
    rm -rf "$new"
    die "couldn't clone $REPO"
  }

  if [ -e "$CONFIG" ]; then
    local backup
    backup="$CONFIG.bak-$(date +%Y%m%d-%H%M%S)"
    info "Moving existing config to $backup"
    mv "$CONFIG" "$backup"
  fi
  mv "$new" "$CONFIG"
}

install_plugins() {
  if ! nvim --headless -c 'if !has("nvim-0.11") | cquit | endif' -c 'qa' >/dev/null 2>&1; then
    warn "this Neovim is too old (needs 0.11+, built on 0.12): $(nvim --version | head -1)"
    warn "skipping plugins. Install a newer Neovim, then open nvim and they will install themselves"
    return
  fi

  # restore keeps every plugin on the version pinned in lazy-lock.json
  info "Installing plugins"
  nvim --headless "+Lazy! restore" +qa
  printf '\n'
}

report_missing() {
  local missing=()
  local tool
  for tool in nvim git rg gcc python3 node npm clang-format cmake bear; do
    command -v "$tool" >/dev/null || missing+=("$tool")
  done
  if [ "${#missing[@]}" -gt 0 ]; then warn "still missing: ${missing[*]}"; fi
}

main() {
  install_packages
  command -v git >/dev/null || die "git isn't installed"
  command -v curl >/dev/null || die "curl isn't installed"
  command -v nvim >/dev/null || die "nvim isn't installed"

  install_config
  install_plugins
  report_missing

  info "Done. Run nvim"
  info "Language servers install in the background on first open (about 1.6 GB), see :Mason"
}

main "$@"
