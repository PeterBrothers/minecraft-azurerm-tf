# minecraft-azurerm-tf
Minecraft on Azure via Terraform

# Overview

## Minecraft server edition
- [Java Edition](https://minecraft.gamepedia.com/Java_Edition)
- [Documentation and step by step process](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server)

## Steps
1. `sudo ufw allow 25565/tcp`
2. `sudo ufw allow 19132/udp`
3. `dmesg | grep SCSI`
4. `sudo fdisk /dev/sdc`
5. `Command (m for help): w`
6. `sudo apt install default-jre`
7. `wget -U "gkama" https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar`
8. `java -Xmx1024M -Xms1024M -jar server.jar nogui`
9. `vi eula.txt` to edit `eula=true`
10. `java -Xmx1024M -Xms1024M -jar server.jar nogui`