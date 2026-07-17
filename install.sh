#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config.bak.$(date +%Y%m%d%H%M%S)"

# ~/.config/ targets
CONFIG_TARGETS=(ghostty niri nvim tmux matugen fcitx5)

# special targets: name -> destination path
declare -A EXTRA_TARGETS=(
  [DankMaterialShell]="$HOME/.local/share/quickshell"
)

info() { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() {
  printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"
  exit 1
}

link_config() {
  local name="$1"
  local src="$2"
  local dst="$3"

  if [ ! -d "$src" ] && [ ! -f "$src" ]; then
    warn "Source not found, skipping: $src"
    return 1
  fi

  # Already a correct symlink
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "Already linked: $dst -> $src"
    return 0
  fi

  # Existing file/dir at destination — back it up
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$name"
    warn "Backed up: $dst -> $BACKUP_DIR/$name"
    backup_count=$((backup_count + 1))
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  info "Linked: $dst -> $src"
  return 0
}

# ── Pre-check ──────────────────────────────────────────────

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  error "Not a valid dotfiles repository: $DOTFILES_DIR"
fi

# ── Submodules ─────────────────────────────────────────────

info "Initializing git submodules..."
git -C "$DOTFILES_DIR" submodule update --init --recursive
info "Submodules ready."

# ── Symlinks ───────────────────────────────────────────────

backup_count=0

# ~/.config/ targets
for name in "${CONFIG_TARGETS[@]}"; do
  link_config "$name" "$DOTFILES_DIR/$name" "$HOME/.config/$name"
done

# Extra targets with custom paths
for name in "${!EXTRA_TARGETS[@]}"; do
  link_config "$name" "$DOTFILES_DIR/$name" "${EXTRA_TARGETS[$name]}"
done

# ── Summary ────────────────────────────────────────────────

echo
if [ "$backup_count" -gt 0 ]; then
  info "Done. $backup_count existing config(s) backed up to: $BACKUP_DIR"
else
  info "Done. All symlinks created."
fi
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config.bak.$(date +%Y%m%d%H%M%S)"

TARGETS=(ghostty niri nvim tmux matugen fcitx5 DankMaterialShell)

info() { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() {
  printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"
  exit 1
}

# ── Pre-check ──────────────────────────────────────────────

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  error "Not a valid dotfiles repository: $DOTFILES_DIR"
fi

# ── Submodules ─────────────────────────────────────────────

info "Initializing git submodules..."
git -C "$DOTFILES_DIR" submodule update --init --recursive
info "Submodules ready."

# ── Symlinks ───────────────────────────────────────────────

backup_count=0

for name in "${TARGETS[@]}"; do
  src="$DOTFILES_DIR/$name"
  dst="$HOME/.config/$name"

  if [ ! -d "$src" ] && [ ! -f "$src" ]; then
    warn "Source not found, skipping: $src"
    continue
  fi

  # Already a correct symlink
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "Already linked: $dst -> $src"
    continue
  fi

  # Existing file/dir at destination — back it up
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$name"
    warn "Backed up: $dst -> $BACKUP_DIR/$name"
    backup_count=$((backup_count + 1))
  fi

  ln -sf "$src" "$dst"
  info "Linked: $dst -> $src"
done

# ── Summary ────────────────────────────────────────────────

echo
if [ "$backup_count" -gt 0 ]; then
  info "Done. $backup_count existing config(s) backed up to: $BACKUP_DIR"
else
  info "Done. All symlinks created."
fi
