#!/bin/bash
cd /root
setfont ter-132n
echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             [Welcome to archinstall!]
      AV/   \VA
     AV/     \VA
     V/       \V

"

bash startup.sh
arch-chroot /mnt /root/archinstall/user.sh
arch-chroot /mnt /root/archinstall/drivers.sh
arch-chroot /mnt /root/archinstall/desktop.sh
arch-chroot /mnt /root/archinstall/standards.sh

echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             [The installation has been finished.]
      AV/   \VA
     AV/     \VA
     V/       \V

"
