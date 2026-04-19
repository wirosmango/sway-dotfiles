#!/usr/bin/env bash
set -e

if command -v apt-get >/dev/null 2>&1; then
    echo "Installing for ALTLinux..."
    sudo apt-get install swayfx rofi mako fastfetch waybar swaybg hyprshot kitty thunar fonts-ttf-jetbrains-mono-nl fonts-font-awesome cliphist wlogout swaylock
    

elif command -v pacman >/dev/null 2>&1; then
    echo "Installing for Arch..."
    yay -S swayfx rofi mako fastfetch waybar swaybg hyprshot kitty thunar ttf-jetbrains-mono otf-font-awesome cliphist wiremix wlogout bluetui swaylock-effects    

else
    echo "Unsupported distro"
    exit 1
fi

chmod +x cliphist-rofi
cp -r * ~/.config

echo "Done!"
