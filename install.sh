#!/usr/bin/env bash
set -e

if command -v apt-get >/dev/null 2>&1; then
    echo "Installing for ALTLinux..."
    sudo apt-get install swayfx rofi mako fastfetch waybar swaybg hyprshot kitty thunar fonts-ttf-jetbrains-mono-nl fonts-font-awesome cliphist swaylock fonts-ttf-fira-code-nerd wireplumber pipewire wayland wayland-protocols
    

elif command -v pacman >/dev/null 2>&1; then
    echo "Installing for Arch..."
    yay -S swayfx rofi mako fastfetch waybar swaybg hyprshot kitty thunar ttf-jetbrains-mono otf-font-awesome cliphist wiremix bluetui swaylock-effects ttf-firacode-nerd wireplumber pipewire wayland wayland-protocols

else
    echo "Unsupported distro"
    exit 1
fi

chmod +x cliphist-rofi 
chmod +x powermenu.sh
chmod +x rofi/emoji-selector.sh
wl-paste --watch cliphist store
cp -r * ~/.config
cp -r ~/.config/powermenu.sh ~/.config/rofi/
echo "Done!"

# burmalda
