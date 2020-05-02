# minecraft-azurerm-tf
Minecraft on Azure via Terraform

# Overview

## Minecraft server edition
- [Java Edition](https://minecraft.gamepedia.com/Java_Edition)
- [Documentation and step by step process](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server)

## Steps
1. `sudo ufw allow 25565/tcp`
2. `sudo ufw allow 19132/udp`
3. `sudo ufw enable`
4. `sudo ufw status`
5. `dmesg | grep SCSI`
6. `sudo fdisk /dev/sdc`
7. `Command (m for help): w`
8. `sudo apt install default-jre`
9. `wget -U "gkama" https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar`
10. `java -Xmx1024M -Xms1024M -jar server.jar nogui`
11. `vi eula.txt` to edit `eula=true`
12. `java -Xmx1024M -Xms1024M -jar server.jar nogui`

Alternative: `java -Xmx2G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -jar server.jar nogui`