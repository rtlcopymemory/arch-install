#!/bin/sh
# This script assumes that you have already partitioned your drive and mounted it into /mnt

REPO_NAME="arch-install"
GITHUB_BASE="https://raw.githubusercontent.com/WolfenCLI/$REPO_NAME/master"

# For a list of desktop visit the repo
DESKTOP="dwm"

TIMEZONE="Europe/Rome"
LOCALE="en_US"
HOSTNAME="wolfencli"
STATIC_IP="192.168.0.105"
DOMAIN="wolfen"

USERNAME="wolfencli"

ARCH="x86_64-efi"
DRIVE="/dev/sda"

UCODE="amd-ucode"
# UCODE="intel-ucode"

VIDEO_DRIVERS="xf86-video-amdgpu mesa" # AMD gpus
# VIDEO_DRIVERS="xf86-video-ati mesa"  # This one is for older Amd/Radeon GPUs
# VIDEO_DRIVERS="xf86-video-intel mesa" # Intel GPUs
# VIDEO_DRIVERS="virtualbox-guest-utils xf86-video-vmware" # Virtualbox
# VIDEO_DRIVERS="nvidia-utils" # NVidia

########## END VARIABLES #############

install_packages()
{
    # Making sure wget is already installed
    pacman -S --needed --noconfirm wget
    wget "$GITHUB_BASE"/packages -O /tmp/packages
    pacman -S --needed --noconfirm - < /tmp/packages
}

install_desktop()
{
    wget "$GITHUB_BASE"/dwm.sh -O /tmp/"$DESKTOP".sh
    source /tmp/"$DESKTOP".sh
}

# Europe/Rome timezone
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc

pacman -S --noconfirm neovim
# opens neovim at the us locale line
nvim +/#"$LOCALE".UTF-8 /etc/locale.gen

cat << EOF > /etc/locale.conf
LANG="$LOCALE".UTF-8
LANGUAGE="$LOCALE"
LC_TIME="$LOCALE".UTF-8
LC_MESSAGES="$LOCALE".UTF-8
EOF
locale-gen

# Sets the hostname and hosts file
echo "$HOSTNAME" > /etc/hostname

cat << EOF >> /etc/hosts
127.0.0.1   localhost
::1         localhost
"$STATIC_IP"    "$HOSTNAME"."$DOMAIN" "$HOSTNAME"
EOF

# Installing base packages
install_packages

# Root password
clear
echo "Please insert your Root Password"
passwd

# Installing grub
grub-install --target="$ARCH" "$DRIVE"

# Installing microcode
pacman -S --noconfirm "$UCODE"

# finishing grub install
grub-mkconfig -o /boot/grub/grub.cfg

# video drivers
pacman -S --noconfirm "$VIDEO_DRIVERS"

# User creation
useradd -m -G wheel,video -s /bin/zsh -U "$USERNAME"
clear
echo "Please insert your user's password"
passwd "$USERNAME"

# SUDO configuration
nvim +/%wheel /etc/sudoers

# Activating Display manager and NetworkManager
systemctl enable NetworkManager
systemctl enable lightdm

# install Desktop
install_desktop

# Touchpad config
cat << EOF > /etc/X11/xorg.conf.d/70-touchpad-settings.conf
Section "InputClass"
    Identifier                   "Touchpads"
    MatchIsTouchpad              "on"
    Option    "Tapping"          "on"
    Option    "NaturalScrolling" "true"
EndSection
EOF

##### DOTFILES
su "$USERNAME"
cd "$HOME"

# ZSH
sudo pacman -S --noconfirm zsh curl git powerline-fonts zsh-autosuggestions
read -s "After the oh-my-zsh prompt appears, press ctrl-D to continue"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Oh-my-zsh theming
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
wget -O "$HOME"/.zshrc https://raw.githubusercontent.com/WolfenCLI/zsh-dotfiles/master/.zshrc

# Alacritty
mkdir "$HOME/.config/alacritty"
wget https://raw.githubusercontent.com/WolfenCLI/alacritty-dotfiles/master/alacritty.yml -O "$HOME/.config/alacritty/alacritty.yml"

# Neovim
mkdir "$HOME/.config/nvim"
wget https://raw.githubusercontent.com/WolfenCLI/neovim-dotfiles/master/init.vim -O "$HOME/.config/nvim/init.vim"

# .profile, .tmux.conf
wget https://raw.githubusercontent.com/WolfenCLI/Personal-Wiki/master/.profile -O "$HOME/.profile"
wget https://raw.githubusercontent.com/WolfenCLI/Personal-Wiki/master/.tmux.conf -O "$HOME/.tmux.conf"

# My own custom scripts
mkdir -p "$HOME/.local/scripts"
mkdir -p "$HOME/.local/bin"
wget https://raw.githubusercontent.com/WolfenCLI/Personal-Wiki/master/sync-pull -O "$HOME/.local/scripts/sync-pull.sh"
wget https://raw.githubusercontent.com/WolfenCLI/Personal-Wiki/master/sync-push -O "$HOME/.local/scripts/sync-push.sh"
chmod 700 "$HOME/.local/scripts/sync-pull.sh"
chmod 700 "$HOME/.local/scripts/sync-push.sh"
ln -s "$HOME/.local/scripts/sync-pull.sh" "$HOME/.local/bin/"
ln -s "$HOME/.local/scripts/sync-push.sh" "$HOME/.local/bin/"

# Adds picom to .profile
echo "picom -b &" >> "$HOME/.profile"

