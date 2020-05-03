# Overview
Minecraft on Azure via Terraform

## Minecraft server edition
- [Minecraft Bedrock edition - Ubuntu](https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/)
- [Documentation and step by step process](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server)

## Steps to setup Bedrock Server
For Minecraft for Windows 10, you can follow the steps outlined in the link below to setup a Bedrock dedicated server on Linux

- [Minecraft Bedrock Edition – Ubuntu Dedicated Server Guide](https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/)

### Installation
```bash
wget https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/SetupMinecraft.sh
chmod +x SetupMinecraft.sh
./SetupMinecraft.sh
```

The script will setup the Minecraft sever and ask you some questions on how to configure it. I’ll explain here what they mean.

“Start Minecraft server at startup automatically (y/n)?” – This will set the Minecraft service to start automatically when your server boots. This is a great option to set up a Minecraft server that is always available.

“Automatically restart and backup server at 4am daily (y/n)?” – This will add a cron job to the server that reboots the server every day at 4am. This is great because every time the server restarts it backs up the server and updates to the latest version. See the “Scheduled Daily Reboots” section below for information on how to customize the time or remove the reboot.

That is it for the setup script. The server will finish configuring and start!

## Steps used with Java server
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