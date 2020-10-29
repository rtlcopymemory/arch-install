#!/bin/sh

pacman -S --noconfirm libxft libxinerama
git clone https://github.com/WolfenCLI/dwm.git /tmp/dwm
cd /tmp/dwm/
make
make install

# Dmenu is also needed
git clone https://git.suckless.org/dmenu /tmp/dmenu
cd /tmp/dmenu
make
make install

mkdir -p /usr/share/xsessions/
cat << EOF > /usr/share/xsessions/dwm.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic Window Manager
Exec=dwm
Icom=dwm
Type=XSession
EOF

pacman -S --noconfirm alacritty dmenu
