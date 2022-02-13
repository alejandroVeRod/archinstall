#!/bin/bash
echo "[Starting] Archinstall User Script"
##Locale
echo -ne "[Running] Locale

"
pacman -S nano bash-completion --noconfirm
echo " "
read -p "Starting locale setup, enter [uk, de, us, utf] to find: " nation
cat /etc/locale.gen | grep $nation
echo " "
read -p "Please enter your locale fully as listed [e.g en_US.UTF-8 UTF-8]: " locale
echo $locale >> /etc/locale.gen
locale-gen
echo " "
read -p "Please enter your locale partially as listed [e.g en_US.UTF-8]: " locale2
echo LANG=$locale2 > /etc/locale.conf
export LANG=$locale2
#Try reusing layout var in startup? To be safe:
echo " "
read -p "Re-enter specific keyboard layout from the search results: " layout3
echo "KEYMAP=$layout3" >> /etc/vconsole.conf
ls /usr/share/zoneinfo
echo " "
read -p "Enter your timezone (Blue names are folders, e.g in Europe there is Berlin): " zone
ln -sf /usr/share/zoneinfo/$zone > /etc/localtime
hwclock --systohc
echo -ne "[Finished] Locale

"

##Multilib
echo -ne "[Running] Multilib, Trim

"
echo [multilib] >> /etc/pacman.conf
echo Include = /etc/pacman.d/mirrorlist >> /etc/pacman.conf
pacman -Sy
#SSD Trim, move somewhere else in future
systemctl enable fstrim.timer
echo -ne "[Finished] Multilib, Trim

"

##Accounts
echo -ne "[Running] Accounts

"
read -p "Enter your systems desired hostname: " hostname
#https://wiki.archlinux.org/title/Installation_guide#Network_configuration
#https://man7.org/linux/man-pages/man5/hosts.5.html
echo $hostname > /etc/hostname
echo 127.0.0.1 localhost >> /etc/hosts
echo ::1       localhost >> /etc/hosts
echo 127.0.1.1 $hostname  >> /etc/hosts
#Root Account
echo "Please set a password for the root account:" && passwd
echo " "
read -p "Please create a user account by entering a user name in lowercase: " useracc
useradd -m -g users -G wheel,storage,power -s /bin/bash $useracc
echo "Please set a password for the user account:" && passwd $useracc
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults rootpw" >> /etc/sudoers

echo -ne "[Finished] Accounts

"

##Efivarfs, Bootctl
echo -ne "[Running] Efivarfs, Bootctl, Services

"
mount -t efivarfs efivarfs /sys/firmware/efi/efivars/
echo "Should already be mounted!"
bootctl install
#https://wiki.archlinux.org/title/dhcpcd
pacman -S dhcpcd --noconfirm
systemctl enable dhcpcd.service
#networkmanager
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager.service
#preparation for drivers module
pacman -S linux-headers --noconfirm

echo -ne "[Finished] Efivarfs, Bootctl, Services

"
clear
echo -ne "[Exiting] Archinstall User Script

"
