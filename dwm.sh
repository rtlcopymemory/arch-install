#!/bin/sh

pacman -S --noconfirm libxft libxinerama
git clone https://github.com/WolfenCLI/dwm.git /tmp/dwm
cd /tmp/dwm/
make
make install
cat << EOF > /usr/share/xsessions/dwm.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic Window Manager
Exec=dwm
Icom=dwm
Type=XSession
EOF

