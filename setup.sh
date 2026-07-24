#!/usr/bin/env bash
set -euo pipefail

info() { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() {
  printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"
  exit 1
}

has() { command -v "$1" &>/dev/null; }

# ── archlinuxcn ────────────────────────────────────────────

setup_archlinuxcn() {
  info "Checking archlinuxcn repository..."
  if ! grep -q "archlinuxcn" /etc/pacman.conf 2>/dev/null; then
    echo "[archlinuxcn]" | sudo tee -a /etc/pacman.conf
    echo "Server = https://repo.archlinuxcn.org/\$arch" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    sudo pacman -S --needed --noconfirm archlinuxcn-keyring
    info "archlinuxcn added."
  else
    info "archlinuxcn already configured."
  fi
}

# ── pacman ─────────────────────────────────────────────────

setup_pacman() {
  info "Installing pacman packages..."
  sudo pacman -Syu --needed --noconfirm \
    nvm fvm jenv pyenv android-tools net-tools tree bat fastfetch \
    curl neovim vim ghostty fcitx5-im fcitx5-rime \
    ttf-jetbrains-mono-nerd wl-clipboard cliphist tmux ripgrep btop \
    zram-generator p7zip reflector jq imv mpv \
    ffmpegthumbnailer gst-plugins-base gst-plugins-good gst-libav \
    ddcutil obs-studio inter-font ttf-fira-code zenity baobab gdu \
    dnsmasq clang cmake os-prober grub efibootmgr dconf-editor wine \
    fsearch less \
    base-devel
  info "pacman packages installed."
}

# ── yay ────────────────────────────────────────────────────

setup_yay() {
  if has yay; then
    info "yay already installed."
  else
    info "Building yay from AUR..."
    mkdir -p ~/develop/github
    git clone https://aur.archlinux.org/yay.git ~/develop/github/yay
    (cd ~/develop/github/yay && makepkg -si --noconfirm)
    rm -rf ~/develop/github/yay
    info "yay installed."
  fi

  info "Installing AUR packages via yay..."
  yay -Syu --noconfirm \
    rime-ice-git ttf-jetbrains-maple-mono-nf-xx-xx \
    visual-studio-code-bin aliyun-adrive-bin clash-verge-rev-bin \
    linuxqq-clipsync-git satty paru android-studio \
    ab-download-manager-bin wps-office-cn
  info "yay packages installed."
}

# ── paru ───────────────────────────────────────────────────

setup_paru() {
  if ! has paru; then
    warn "paru not found, installing via yay..."
    yay -S --noconfirm paru
  fi

  info "Installing AUR packages via paru..."
  paru -S --noconfirm ttf-maplemono-nf-cn-unhinted wf-recorder
  info "paru packages installed."
}

# ── fonts ──────────────────────────────────────────────────

setup_fonts() {
  info "Configuring fontconfig..."
  local fontconfig_dir="$HOME/.config/fontconfig"
  mkdir -p "$fontconfig_dir"

  if [ ! -f "$fontconfig_dir/fonts.conf" ]; then
    cat >"$fontconfig_dir/fonts.conf" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Maple Mono NF CN</family>
      <family>Maple Mono NF</family>
      <family>JetBrainsMono Nerd Font</family>
    </prefer>
  </alias>
</fontconfig>
EOF
    info "fontconfig written."
  else
    info "fontconfig already exists, skipping."
  fi

  # K2D font
  local k2d_dir="$HOME/.local/share/fonts/truetype/K2D"
  if [ ! -d "$k2d_dir" ]; then
    info "Downloading K2D font..."
    mkdir -p "$k2d_dir"
    curl -s "https://fonts.google.com/download/list?family=K2D" |
      sed '1s/^)]}'\''//' |
      jq -r '.manifest.fileRefs[] | select(.url != null and (.filename | endswith(".ttf"))) | "\(.url)\t\(.filename)"' |
      xargs -r -n 2 -P 8 sh -c 'curl -L -# -o "$HOME/.local/share/fonts/truetype/K2D/$2" "$1"' _
    info "K2D font installed."
  else
    info "K2D font already installed, skipping."
  fi

  # GTK font
  info "Setting GTK font..."
  gsettings set org.gnome.desktop.interface font-name 'K2D:weight=semibold 11'

  # Refresh font cache
  fc-cache -fv
  info "Font cache refreshed."
}

# ── cursor ─────────────────────────────────────────────────

setup_cursor() {
  info "Installing BreezeX cursor themes..."
  local icons_dir="$HOME/.local/share/icons"
  mkdir -p "$icons_dir"

  local installed=0
  for variant in Dark Light Black; do
    if [ ! -d "$icons_dir/BreezeX-${variant}" ]; then
      curl -L "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-${variant}.tar.xz" |
        tar -xJ -C "$icons_dir/"
      installed=$((installed + 1))
    else
      info "BreezeX-${variant} already installed."
    fi
  done

  if [ "$installed" -gt 0 ]; then
    info "BreezeX cursors installed."
  fi
}

# ── memory (zram + swap) ──────────────────────────────────

setup_memory() {
  info "Configuring zram (8 GB)..."
  if [ ! -f /etc/systemd/zram-generator.conf ] || ! grep -q "zram0" /etc/systemd/zram-generator.conf; then
    echo -e "[zram0]\nzram-size = min(ram, 8192)\ncompression-algorithm = zstd" |
      sudo tee /etc/systemd/zram-generator.conf
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-zram-setup@zram0.service
    info "zram configured."
  else
    info "zram already configured."
  fi

  info "Configuring swapfile (10 GB)..."
  if ! grep -q "/swapfile" /etc/fstab 2>/dev/null; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=10240 status=progress
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
    info "Swap configured."
  else
    info "Swap already configured."
  fi

  zramctl && swapon --show && free -h
}

# ── brightness ─────────────────────────────────────────────

setup_brightness() {
  info "Configuring brightness control (ddcutil)..."
  sudo modprobe i2c_dev
  echo "i2c_dev" | sudo tee /etc/modules-load.d/i2c_dev.conf
  sudo pacman -S --needed --noconfirm ddcutil
  sudo usermod -aG i2c "$USER"
  info "Brightness control configured. Re-login required for group change."
}

# ── fcitx5 themes ──────────────────────────────────────────

setup_fcitx5() {
  info "Installing fcitx5 mellow themes..."
  local themes_dir="$HOME/.local/share/fcitx5/themes"
  if [ ! -d "$themes_dir" ] || [ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]; then
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    git clone https://github.com/sanweiya/fcitx5-mellow-themes.git "$tmp_dir/fcitx5-mellow-themes"
    mkdir -p "$themes_dir"
    cp -r "$tmp_dir/fcitx5-mellow-themes/mellow-"* "$themes_dir/"
    rm -rf "$tmp_dir"
    info "fcitx5 themes installed."
  else
    info "fcitx5 themes already installed."
  fi

  # Rime config
  info "Configuring rime..."
  local rime_dir="$HOME/.local/share/fcitx5/rime"
  mkdir -p "$rime_dir"
  if [ ! -f "$rime_dir/default.custom.yaml" ]; then
    cat >"$rime_dir/default.custom.yaml" <<'EOF'
patch:
  schema_list:
    - schema: rime_ice
  "menu/page_size": 5
  key_binder/bindings:
    - { accept: bracketleft, send: Page_Up, when: has_menu }
    - { accept: bracketright, send: Page_Down, when: has_menu }
    - { accept: Left, send: Up, when: has_menu }
    - { accept: Right, send: Down, when: has_menu }
EOF
    info "rime config written."
  else
    info "rime config already exists, skipping."
  fi
}

# ── workspace directories ──────────────────────────────────

setup_directories() {
  info "Creating workspace directories..."
  mkdir -p ~/develop/github ~/develop/work ~/develop/agents
  info "Directories ready."
}

# ── Main ───────────────────────────────────────────────────

echo
echo "  Arch Linux Environment Setup"
echo "  ============================"
echo

setup_archlinuxcn
setup_pacman
setup_yay
setup_paru
setup_directories
setup_fonts
setup_cursor
setup_memory
setup_brightness
setup_fcitx5

echo
info "Setup complete. Re-login may be required for some changes to take effect."
