#!/bin/bash
echo "[Starting] Archinstall Desktop Script"
##XORG, SDDM, KDE
echo -ne "[Running] XORG, SDDM, KDE

"
pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock xterm --noconfirm
pacman -S sddm --noconfirm
systemctl enable sddm.service
pacman -S plasma bluez bluez-tools firewalld ntfs-3g exfatprogs network-manager-applet system-config-printer cups --noconfirm
pacman -R discover --noconfirm
systemctl enable bluetooth.service
systemctl enable firewalld.service
systemctl enable cups.service
echo -ne "[Finished] XORG, SDDM, KDE

"

##ALSA-Pulse
echo -ne "[Running] ALSA, Pulse

"
pacman -S pulseaudio pulseaudio-alsa alsa-plugins libpulse lib32-libpulse lib32-alsa-plugins pavucontrol --noconfirm
echo -ne "[Finished] ALSA, Pulse

"

##Standard Applications
echo -ne "[Running] Standard Applications

"
#Main
pacman -S lm_sensors mpv celluloid thunderbird firefox discord gimp okular kate kuickshow ksystemlog papirus-icon-theme neofetch spectacle konsole partitionmanager dolphin ark unrar colord-kde kcalc arch-wiki-docs htop --noconfirm --needed
#LibreOffice
pacman -S libreoffice-still ttf-caladea ttf-carlito ttf-dejavu ttf-liberation ttf-linux-libertine-g noto-fonts noto-fonts-cjk noto-fonts-emoji --noconfirm --needed
#OBS
pacman -S ffmpeg obs-studio --noconfirm
#Emus
pacman -S ppsspp desmume pcsx2 realtime-privileges --noconfirm
#GameDev
read -p "Install Game Dev Suite (Godot, Blender3D) (Y/n)? " gameDev
if [ $gameDev == "y" ] || [ $gameDev == "Y" ]; then
    pacman -S godot
    pacman -S blender

echo " "
read -p "Please re-enter your user account name in lowercase: " useracc2
usermod -a -G realtime $useracc2
echo "*      soft      memlock      unlimited" >> /etc/security/limits.conf
echo "*      soft      memlock      unlimited" >> /etc/security/limits.conf
#VMs(1)
pacman -S dnsmasq qemu libvirt virt-manager -noconfirm
pacman -S ebtables
usermod -G libvirt -a $useracc2
systemctl enable libvirtd.service
#VMs(2)
pacman -S virtualbox-host-dkms virtualbox virtualbox-guest-iso --noconfirm
usermod -G vboxusers -a $useracc2
echo -ne "[Finished] Standard Applications

"
clear
echo -ne "[Exiting] Archinstall Desktop Script

"
