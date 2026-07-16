<div align="center">

# dotfiles

Personal configuration files for Arch Linux.

</div>

## Overview

| Program      | Description                       |
| ------------ | --------------------------------- |
| **niri**     | Wayland compositor                |
| **ghostty**  | Terminal emulator                 |
| **nvim**     | Text editor (based on LazyVim)    |
| **tmux**     | Terminal multiplexer (oh-my-tmux) |
| **matugen**  | Color scheme generator            |

## Installation

```bash
git clone https://github.com/crowforkotlin/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will:

1. Initialize all git submodules
2. Back up any existing configs in `~/.config/`
3. Create symbolic links from dotfiles to `~/.config/`

## Documentation

Detailed setup guide:
[`Arch-Linux-Config.md`](https://github.com/crowforkotlin/crowforkotlin.github.io-source/blob/master/source/_posts/Unix/Arch-Linux-Config.md)
