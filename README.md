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

#### Server properties
Changing server properties, such as `pvp` are done via the `server.properties` file. Available values can be found [here](https://minecraft.gamepedia.com/Server.properties)

## Steps to load saved server to the Bedrock server
Okay, so first - you don't want to convert the world to a .mcworld file. Here's what you want to do:

1. Load your world in Windows 10 as a local world, close minecraft
2. Open file explorer
3. Navigate to: C:\Users\username\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftWorlds\ - where 'username' is your own windows username. There will be a folder (or multiple folders, one for each world you have in the Win 10 version) with a random name like 'BQUAAIFxEAA='. Find the one that is the world you want to put on your dedicated server by checking 'levelname.txt'
4. Copy the entire contents of this folder (db folder, level.dat, etc.. - everything in there)
5. Create a folder for the level in the 'worlds' folder on your bedrock server, name it the exact same thing that was in 'levelname.txt', and then paste the contents in there.
6. Open server.properties on your bedrock server, and find the 'level-name=' line, enter the name of the folder you created in step 5 here (spaces are okay) so that it looks something like level-name=My Server Level - this should exactly match the folder name and level name (as found in levelname.txt)
7. Start your bedrock server and it should now have your imported world running
8. Copy local world folders and files to server via `scp`. Open `powershell` and run the command below
```powershell
scp -r C:\Users\{username}\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftWorlds\{worldname} {username}@{server ip}:"'/home/{admin username}/minecraftbe/{world name}/worlds/Bedrock level'"
```

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