# arch-install
My personal scripts to install and configure arch

# How to use
after partitioning your disk, mounting the needed partitions to `/mnt` and `arch-chroot` into it run:
```sh
pacman -S wget neovim
wget https://raw.githubusercontent.com/WolfenCLI/arch-install/master/init.sh
neovim init.sh
sh ./init.sh
rm /init.sh
```
