#!/bin/bash
echo "[Starting] Archinstall Startup Script"
clear
##Keymap
echo -ne "[Running] Keymap

"
read -p "Please select your desired keymap [de, us, uk ...]: " layout
localectl list-keymaps | grep $layout
echo " "
read -p "Enter specific keyboard layout from the search results: " layout2
loadkeys $layout2
echo -ne "[Finished] Keymap

"

##WiFi
echo -ne "[Running] WiFi

"
#https://wiki.archlinux.org/title/Network_configuration/Wireless#Utilities
ip -c a
echo " "
read -p "Set-up WiFi Connection (Y/n)? " wifi
if [ $wifi == "y" ] || [ $wifi == "Y" ]; then
    read -p "Enter the WiFi device name [wlan0, wlan1]: " wdev
    read -p "Enter the SSID / name of your WiFi network: " ssid
    echo "Connecting, please enter your WiFi password:"
    iw dev $wdev connect $ssid
    echo "Attempting sync..."
    pacman -Sy
elif [ $wifi == "n" ] || [ $wifi == "N" ]; then
    echo "Skipping..."
fi
echo -ne "[Finished] WiFi

"

##Partitioning
echo -ne "[Running] Partitioning

"
#https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html
#https://linux.die.net/man/8/sgdisk
sgdisk -p /dev/sda && echo " "
sgdisk -p /dev/sdb && echo " "
sgdisk -p /dev/sdc && echo " "
sgdisk -p /dev/sdd && echo " "
read -p "Please choose the drive you want to use (WARN: The drive will be wiped entirely): " drive
sgdisk --zap-all /dev/$drive
echo -ne "Starting the partitioning process, see the example for a 1TB SSD:

  'NEW', first sector hit ENTER for default
  Size enter 512MiB, ENTER; Specfiy efi boot partition, type: EF00
  Then enter name: 'boot'; Move down to the rest of the free space, ENTER

  First sector hit ENTER for default
  Size enter 16GiB, ENTER; Specfiy swap partition, type: 8200
  Then enter name: 'swap'; Move down to the rest of the free space, ENTER

  First sector hit ENTER for default
  Size enter 100GiB, ENTER; Specfiy linux fs partition, type: 8300
  Then enter name: 'root'; Move down to the rest of the free space, ENTER

  First sector hit ENTER for default
  Size press ENTER to use the rest of the drive; Specfiy linux fs partition, type: 8300
  Then enter name: 'home'; Move over to 'WRITE' and hit ENTER, type 'yes', then move to 'QUIT'

"
read -p "Press any key to continue..."
cgdisk /dev/$drive
mkfs.fat -F32 /dev/${drive}1
mkswap /dev/${drive}2
swapon /dev/${drive}2
echo " "
read -p "Please specify your desired 'root' and 'home' partition filesystem [ext4, btrfs]: " partfs
mkfs.$partfs /dev/${drive}3
mkfs.$partfs /dev/${drive}4
mount /dev/${drive}3 /mnt && mkdir /mnt/boot && mkdir /mnt/home
mount /dev/${drive}1 /mnt/boot
mount /dev/${drive}4 /mnt/home
lsblk
echo -ne "[Finished] Partitioning

"

##Ranking Mirrors
echo -ne "[Running] Mirrors

"
clear
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
pacman -S pacman-contrib --noconfirm
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
echo -ne "[Finished] Mirrors

"

##Basic OS Packages
echo -ne "[Running] Pacstrap

"
pacstrap -i /mnt base base-devel linux linux-firmware linux-headers --noconfirm
genfstab -U -p /mnt >> /mnt/etc/fstab
echo -ne "[Finished] Pacstrap

"

echo -ne "[Exiting] Archinstall Startup Script

"
