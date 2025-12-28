- `vim ~/.config/niri/config.kdl`
# NIRI 配置指定 ghostty终端圆角外观
```
window-rule {
    // 使用正则表达式匹配两种常见的 app-id
    match app-id="com.mitchellh.ghostty"
    geometry-corner-radius 12
    clip-to-geometry true
}
```

# NIRI 设置ghostty作为终端
```
binds {
    Alt+T { spawn "ghostty"; }
}
```

# NIR Wsl去掉窗口装饰
git clone https://github.com/YaLTeR/niri.git
cd niri
vim src/backend/winit.rs
``` bash
41   │         let builder = Window::default_attributes()
42   │             .with_inner_size(LogicalSize::new(1280.0, 800.0))
43   │             // .with_resizable(false)
44 + │             .with_decorations(false)  // 添加这一行，禁用 winit CSD
45   │             .with_title("niri");
46   │         let (backend, winit) = winit::init_from_attributes(builder)?;
```bash
pacman -S rustup base-devel clang
rustup default stable
cargo build --release
cp target/release/niri /usr/sbin/niri
