# minecraft-azurerm-tf
Minecraft on Azure via Terraform

# Overview

## Minecraft server edition
- [Java Edition](https://minecraft.gamepedia.com/Java_Edition)
- [Documentation and step by step process](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server)

## Steps
1. `sudo ufw allow 25565/tcp`
2. `sudo apt install default-jre`
3. `wget -u "gkama" https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar`
4. `java -Xmx1024M -Xms1024M -jar server.jar nogui`
5. `vi eula.txt` - edit `eula=true`
6. `java -Xmx1024M -Xms1024M -jar server.jar nogui`