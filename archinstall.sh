#!/bin/bash
cd /root
setfont ter-132n
echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             STARTING
      AV/   \VA
     AV/     \VA
     V/       \V

"

bash startup.sh
bash user.sh
bash drivers.sh
bash desktop.sh
bash standards.sh

echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             FINISHED
      AV/   \VA
     AV/     \VA
     V/       \V

"
