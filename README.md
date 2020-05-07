# Overview
Minecraft (Bedrock server) on Microsoft Azure via Terraform

## Terraform
The `main.tf` script uses `terraform.tfvars` file for sensitive configuration information that is used to create the Microsoft Azure resources

```terraform
subscription_id = ""
tenant_id = ""
client_id = ""
client_secret = ""
location = ""
environment = ""

admin_username = ""
admin_password = ""

machine_ip = ""
```

### Resources
This `terraform` script will create the following resources
- Virtual network (default) - it is needed but not really used
- Network interface (default) - it is needed but not really used
- Public IP address - creates the IP that you can use to SSH into or players can use to connect
- Disk (os) - OS disk created for the VM
- Disk (server) - I added an SSD extra disk to hold the server. This can later be attached and moved, backedup (snapshot), etc. It is a separation of concern from the actual VM and the OS disk
- Virtual Machine - the VM that hosts the server
- Network security group - used to control SSH access and opens port `19312` to connect to the server

#### Mounting the disk to the VM
A next step, after creating your Microsoft Azure resources, is to SSH into the VM and mount the SSD disk - which is the disk that will host our Minecraft Bedrock server. One great resource for that is [this Microsoft documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal#connect-to-the-linux-vm-to-mount-the-new-disk)



## Minecraft server edition
- [Bedrock server](https://www.minecraft.net/en-us/download/server/bedrock/)

## Complete guide
For Minecraft for Windows 10, you can follow the complete guide outlined in the link below to setup a Bedrock dedicated server on Linux
- [Minecraft Bedrock Edition – Ubuntu Dedicated Server Guide](https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/)

## Installation
```bash
wget https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/SetupMinecraft.sh
chmod +x SetupMinecraft.sh
./SetupMinecraft.sh
```

The script will setup the Minecraft sever and ask you some questions on how to configure it.

“Start Minecraft server at startup automatically (y/n)?” – This will set the Minecraft service to start automatically when your server boots. This is a great option to set up a Minecraft server that is always available.

“Automatically restart and backup server at 4am daily (y/n)?” – This will add a cron job to the server that reboots the server every day at 4am. This is great because every time the server restarts it backs up the server and updates to the latest version. See the “Scheduled Daily Reboots” section below for information on how to customize the time or remove the reboot.

That is it for the setup script. The server will finish configuring and start!

### Server properties
Changing [server properties](https://minecraft.gamepedia.com/Server.properties) is the file that stores all the settings for a multiplayer server. Settings, such as `pvp`, are done via the `server.properties` file inside your server folder. Available values can be found [here](https://minecraft.gamepedia.com/Server.properties#Minecraft_server_properties)

### Whitelist
[Whitelist](https://minecraft.gamepedia.com/Whitelist.json) is a server configuration file that stores the usernames of players who have been whitelisted on a server. The file is `whitelist.json`. To activate the whitelist, the `white-list` value in `server.properties` must be changed to `true`: `white-list=true`. This will then only allow the named users to connect to the server

```json
[
    {
        "name": "",
        "xuid": ""
    },
    {
        "name": "",
        "xuid": ""
    }
]
```

### Permissions
Permissions are stored in the `permissions.json` file. This file controls the level of permissions a player has

```json
[
    {
        "permission": "operator",
        "xuid": ""
    }
]

```

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

## Documentation
- [Minecraft Bedrock edition - Ubuntu](https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/)
- [Documentation and step by step process](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server)
- [Bedrock server](https://www.minecraft.net/en-us/download/server/bedrock/)