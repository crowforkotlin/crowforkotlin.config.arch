<div align="left">

# dotfiles

Personal configuration files for Arch Linux.

</div>

## Overview

| Program                | Description                       |
| ---------------------- | --------------------------------- |
| **niri**               | Wayland compositor                |
| **ghostty**            | Terminal emulator                 |
| **nvim**               | Text editor (based on LazyVim)    |
| **tmux**               | Terminal multiplexer (oh-my-tmux) |
| **matugen**            | Color scheme generator            |
| **fcitx5**             | Input method framework            |
| **DankMaterialShell**  | QuickShell desktop UI             |

## Installation

### Dotfiles sync

```bash
git clone https://github.com/crowforkotlin/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Initialize submodules, back up existing configs, and create symbolic links.

### System environment

```bash
./setup.sh
```

Install packages (pacman / yay / paru), configure fonts, cursor, swap, and brightness.

## Scripts

| Script         | Purpose                                  |
| -------------- | ---------------------------------------- |
| `install.sh`   | Submodule init + symlink deployment      |
| `setup.sh`     | System packages and environment config   |

## Documentation

Full setup guide:
[`Arch-Linux-Config.md`](https://github.com/crowforkotlin/crowforkotlin.github.io-source/blob/master/source/_posts/Unix/Arch-Linux-Config.md)
