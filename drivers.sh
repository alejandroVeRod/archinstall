#!/bin/bash
echo "[Starting] Archinstall Drivers Script"
##Drivers
echo -ne "[Running] Drivers

"
#Probing for CPU model, downloading ucode, regenerating bootloader default.conf
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Intel microcode: Installing and regenerating bootloader default.conf"
    pacman -Sy --noconfirm intel-ucode
    echo -ne "title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
    " > /boot/loader/entries/default.conf
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "AMD microcode: Installing and regenerating bootloader default.conf"
    pacman -Sy --noconfirm amd-ucode
    echo -ne "title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
    " > /boot/loader/entries/default.conf
fi

#Probing for GPU model
#NVIDIA: regenerate mkinitcpio.conf, bootloader default.conf and create pacman hook...
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S mesa lib32-mesa nvidia-dkms nvidia-utils opencl-nvidia lib32-opencl-nvidia libglvnd lib32-libglvnd lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
    # Package "nvidia" not needed? Apparently blacklists Nouveau...
    # Nouveau: "xf86-video-nouveau" would be all? (open source nvidia driver, avoid)
    # ___________________________________________
    # Changing bootloader default.conf, append:
    echo "options root=PARTLABEL=root rw nvidia-drm.modeset=1" >> /boot/loader/entries/default.conf
    # ___________________________________________
    # Regenerate mkinitcpio.conf entirely:
    echo -ne "# vim:set ft=sh
# MODULES
# The following modules are loaded before any boot hooks are
# run.  Advanced users may wish to specify all system modules
# in this array.  For instance:
#     MODULES=(piix ide_disk reiserfs)
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

# BINARIES
# This setting includes any additional binaries a given user may
# wish into the CPIO image.  This is run last, so it may be used to
# override the actual binaries included by a given hook
# BINARIES are dependency parsed, so you may safely ignore libraries
BINARIES=()

# FILES
# This setting is similar to BINARIES above, however, files are added
# as-is and are not parsed in any way.  This is useful for config files.
FILES=()

# HOOKS
# This is the most important setting in this file.  The HOOKS control the
# modules and scripts added to the image, and what happens at boot time.
# Order is important, and it is recommended that you do not change the
# order in which HOOKS are added.  Run 'mkinitcpio -H <hook name>' for
# help on a given hook.
# 'base' is _required_ unless you know precisely what you are doing.
# 'udev' is _required_ in order to automatically load modules
# 'filesystems' is _required_ unless you specify your fs modules in MODULES
# Examples:
##   This setup specifies all modules in the MODULES setting above.
##   No raid, lvm2, or encrypted root is needed.
#    HOOKS=(base)
#
##   This setup will autodetect all modules for your system and should
##   work as a sane default
#    HOOKS=(base udev autodetect block filesystems)
#
##   This setup will generate a 'full' image which supports most systems.
##   No autodetection is done.
#    HOOKS=(base udev block filesystems)
#
##   This setup assembles a pata mdadm array with an encrypted root FS.
##   Note: See 'mkinitcpio -H mdadm' for more information on raid devices.
#    HOOKS=(base udev block mdadm encrypt filesystems)
#
##   This setup loads an lvm2 volume group on a usb device.
#    HOOKS=(base udev block lvm2 filesystems)
#
##   NOTE: If you have /usr on a separate partition, you MUST include the
#    usr, fsck and shutdown hooks.
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)

# COMPRESSION
# Use this to compress the initramfs image. By default, zstd compression
# is used. Use 'cat' to create an uncompressed image.
#COMPRESSION=\"zstd\"
#COMPRESSION=\"gzip\"
#COMPRESSION=\"bzip2\"
#COMPRESSION=\"lzma\"
#COMPRESSION=\"xz\"
#COMPRESSION=\"lzop\"
#COMPRESSION=\"lz4\"

# COMPRESSION_OPTIONS
# Additional options for the compressor
#COMPRESSION_OPTIONS=()
    " > /etc/mkinitcpio.conf
    # ___________________________________________
    # Create Nvidia Pacman Hook ("nvidia", "nvidia.hook" both work):
    mkdir /etc/pacman.d/hooks
    echo -ne "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia

[Action]
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P
    " > /etc/pacman.d/hooks/nvidia
    # ___________________________________________
    echo "Nvidia GPU: Done. Changed mkinitcpio.conf, bootloader default.conf and created pacman hook."
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools --noconfirm
    echo "options root=PARTLABEL=root rw" >> /boot/loader/entries/default.conf
    echo "AMD GPU: done. No further config needed."
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S mesa lib32-mesa libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools --noconfirm
    # Packages "vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader" might be enough, DE-specific?
    # What about "xf86-video-intel"? Often not recommended.
    echo "options root=PARTLABEL=root rw" >> /boot/loader/entries/default.conf
    echo "Intel GPU: Done. No further config needed."
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S mesa lib32-mesa libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools --noconfirm
    # Packages "vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader" might be enough, DE-specific?
    # What about "xf86-video-intel"? Often not recommended.
    echo "options root=PARTLABEL=root rw" >> /boot/loader/entries/default.conf
    echo "Intel GPU: Done. No further config needed."
elif grep -E "VMware SVGA II Adapter" <<< ${gpu_type}; then
    pacman -S mesa lib32-mesa xf86-video-vmware vulkan-tools --noconfirm
    echo "options root=PARTLABEL=root rw" >> /boot/loader/entries/default.conf
    # VirtualBox uses this.
    echo "VMware GPU: Done. No further config needed."
elif grep -E "Red Hat, Inc. QXL paravirtual graphic card" <<< ${gpu_type}; then
    pacman -S mesa lib32-mesa xf86-video-qxl vulkan-tools --noconfirm
    echo "options root=PARTLABEL=root rw" >> /boot/loader/entries/default.conf
    # KVM, QEMU, libvirt, virt-manager uses this.
    echo "VM QXL GPU: Done. No further config needed."
fi

echo -ne "
[Finished] Drivers

"
clear
echo -ne "[Exiting] Archinstall Drivers Script

"


