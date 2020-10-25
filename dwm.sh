#!/bin/sh

pacman -S --noconfirm libxft libxinerama
git clone https://github.com/WolfenCLI/dwm.git /tmp/dwm
cd /tmp/dwm/
make
make install

