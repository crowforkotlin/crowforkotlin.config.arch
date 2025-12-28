```bash
wsl --unregister ArchLinux
wsl --uninstall ArchLinux
wsl --install ArchLinux
wsl -d ArchLinux

# 修改自己IP
echo 'export http_proxy="192.168.0.54:7890"' >> ~/.bashrc
echo 'export https_proxy="192.168.0.54:7890"' >> ~/.bashrc
echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc
source ~/.bashrc
curl -I www.google.com

# 安装pacman并下载VIM和sudo
pacman -Syu
pacman -S vim sudo

# 设置系统语言，不然文件有的会有乱码报错等...
vim /etc/locale.gen

# 搜索对应的语言，一般都用en_US.UTF-8 UTF-8 取消注释保存退出
locale-gen

# 开启下载带有进度 找到Color并取消注释，并注释掉NoProgressBar
vim /etc/pacman.conf

# 创建自己的用户名并设置root和(root密码，用户密码)
useradd -m -G wheel wuya
usermod -aG wheel wuya
passwd
passwd wuya
EDITOR=vim visudo
#找到并取消注释这一行
'%wheel ALL=(ALL:ALL) ALL'

# VIM + ZSH 基础配置
git clone https://github.com/crowforkotlin/QuickShell ~/QuickShell && cd ~/QuickShell
sh init_vim.sh
sh init_zsh.sh

# 安装必备的工具
pacman -S git curl wget tree bat niri fuzzel ghostty xdg-desktop-portal-gtk xwayland-satellite xdg-desktop-portal-gnome wl-clipboard

# 切换用户级别
su - wuya
git clone https://aur.archlinux.org/yay.git && cd yay/ && makepkg -si

# 回到root用户，安装剪贴工具 后续配合脚本解决windows和niri复制粘贴互通
yay -S clipse-bin clipse-gui

# 【核心，和windows剪贴板互通】
vim ~/.config/niri/config.kdl
cd ~ & mkdir github & git clone https://github.com/crowforkotlin/crowforkotlin.config.arch.git ./ 
spawn-sh-at-startup "bash ~/.local/bin/wsl-clipboard-sync > /tmp/clipboard.log 2>&1"

# 以上配置完成，接下来参考cofig-niri.md优化niri
```
