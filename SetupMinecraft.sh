!/bin/bash
 Custom Minecraft server install script for Ubuntu 15.04
 $1 = "RoobyRacks"
 $2 = "1"
 $3 = "Big Iron on His Hip"
 $4 = "0"
 $5 = "RoobyRacks"
 $6 = "true"
 $7 = "true"
 $8 = "true"
 #$9 = level-seed

# basic service and API settings
minecraft_server_path=/srv/minecraft_server
minecraft_user=minecraft
minecraft_group=minecraft
UUID_URL=https://api.mojang.com/users/profiles/minecraft/$1

# screen scrape the server jar location from the Minecraft server download page
SERVER_JAR_URL="curl -L https://minecraft.net/en-us/download/server/ | grep -Eo \"(http|https)://[a-zA-Z0-9./?=_-]*\" | sort | uniq | grep launcher"
server_jar=server.jar

# add and update repos
while ! echo y | apt-get install -y software-properties-common; do
    sleep 10
    apt-get install -y software-properties-common
done

while ! echo y | apt-add-repository -y ppa:linuxuprising/java; do
    sleep 10
    apt-add-repository -y ppa:linuxuprising/java
done

while ! echo y | apt-get update; do
    sleep 10
    apt-get update
done

# Install Java12
echo oracle-java12-installer shared/accepted-oracle-license-v1-2 select true | /usr/bin/debconf-set-selections

while ! echo y | apt-get install -y oracle-java12-installer; do
    sleep 10
    apt-get install -y oracle-java12-installer
done

# create user and install folder
adduser --system --no-create-home --home $minecraft_server_path $minecraft_user
addgroup --system $minecraft_group
mkdir $minecraft_server_path
cd $minecraft_server_path

# download the server jar
while ! echo y | wget `eval $SERVER_JAR_URL`; do
    sleep 10
    wget `eval $SERVER_JAR_URL`
done

# set permissions on install folder
chown -R $minecraft_user $minecraft_server_path

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 2048 ]; then
    memoryAllocs=512m
    memoryAllocx=1g
else
    memoryAllocs=1g
    memoryAllocx=2g
fi

# create the eula file
touch $minecraft_server_path/eula.txt
echo 'eula=true' >> $minecraft_server_path/eula.txt

# create a service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/%s nogui\n' $memoryAllocs $memoryAllocx $minecraft_server_path $server_jar >> /etc/systemd/system/minecraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=minecraft-server.service' >> /etc/systemd/system/minecraft-server.service
chmod +x /etc/systemd/system/minecraft-server.service

# create a valid operators file using the Mojang API
touch $minecraft_server_path/ops.json
mojang_output="`wget -qO- $UUID_URL`"
rawUUID=${mojang_output:7:32}
UUID=${rawUUID:0:8}-${rawUUID:8:4}-${rawUUID:12:4}-${rawUUID:16:4}-${rawUUID:20:12}
printf '[\n {\n  \"uuid\":\"%s\",\n  \"name\":\"%s\",\n  \"level\":4\n }\n]' $UUID $1 >> $minecraft_server_path/ops.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/ops.json

# set user preferences in server.properties
touch $minecraft_server_path/server.properties
chown $minecraft_user:$minecraft_group $minecraft_server_path/server.properties
# echo 'max-tick-time=-1' >> $minecraft_server_path/server.properties
printf 'difficulty=%s\n' $2 >> $minecraft_server_path/server.properties
printf 'level-name=%s\n' $3 >> $minecraft_server_path/server.properties
printf 'gamemode=%s\n' $4 >> $minecraft_server_path/server.properties
printf 'white-list=%s\n' $5 >> $minecraft_server_path/server.properties
printf 'enable-command-block=%s\n' $6 >> $minecraft_server_path/server.properties
printf 'spawn-monsters=%s\n' $7 >> $minecraft_server_path/server.properties
printf 'generate-structures=%s\n' $8 >> $minecraft_server_path/server.properties
printf 'level-seed=%s\n' $9 >> $minecraft_server_path/server.properties

systemctl start minecraft-server

# #!/bin/bash
# # Minecraft Server Installation Script - James A. Chambers - https://jamesachambers.com
# #
# # Instructions: https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/
# # To run the setup script use:
# # wget https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/SetupMinecraft.sh
# # chmod +x SetupMinecraft.sh
# # ./SetupMinecraft.sh
# #
# # GitHub Repository: https://github.com/TheRemote/MinecraftBedrockServer

# echo "Minecraft Bedrock Server installation script by James Chambers - July 24th 2019"
# echo "Latest version always at https://github.com/TheRemote/MinecraftBedrockServer"
# echo "Don't forget to set up port forwarding on your router!  The default port is 19132"

# # Function to read input from user with a prompt
# function read_with_prompt {
#   variable_name="$1"
#   prompt="$2"
#   default="${3-}"
#   unset $variable_name
#   while [[ ! -n ${!variable_name} ]]; do
#     read -p "$prompt: " $variable_name < /dev/tty
#     if [ ! -n "`which xargs`" ]; then
#       declare -g $variable_name=$(echo "${!variable_name}" | xargs)
#     fi
#     declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
#     if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
#       declare -g $variable_name=$default
#     fi
#     echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
#     read answer < /dev/tty
#     if [ "$answer" == "${answer#[Yy]}" ]; then
#       unset $variable_name
#     else
#       echo "$prompt: ${!variable_name}"
#     fi
#   done
# }

# # Install dependencies required to run Minecraft server in the background
# echo "Installing screen, unzip, sudo, net-tools, wget.."
# if [ ! -n "`which sudo`" ]; then
#   apt-get update && apt-get install sudo -y
# fi
# sudo apt-get update
# sudo apt-get install screen unzip wget -y
# sudo apt-get install net-tools -y
# sudo apt-get install libcurl4 -y
# sudo apt-get install openssl -y

# # Check to see if Minecraft server main directory already exists
# cd /minecraft
# if [ ! -d "minecraftbe" ]; then
#   mkdir minecraftbe
#   cd minecraftbe
# else
#   cd minecraftbe
#   if [ -f "bedrock_server" ]; then
#     echo "Migrating old Bedrock server to minecraftbe/old"
#     cd /minecraft
#     mv minecraftbe old
#     mkdir minecraftbe
#     mv old minecraftbe/old
#     cd minecraftbe
#     echo "Migration complete to minecraftbe/old"
#   fi
# fi

# # Server name configuration
# echo "Enter a short one word label for a new or existing server..."
# echo "It will be used in the folder name and service name..."

# read_with_prompt ServerName "Server Label"

# echo "Enter server IPV4 port (default 19132): "
# read_with_prompt PortIPV4 "Server IPV4 Port" 19132

# echo "Enter server IPV6 port (default 19133): "
# read_with_prompt PortIPV6 "Server IPV6 Port" 19133

# if [ -d "$ServerName" ]; then
#   echo "Directory minecraftbe/$ServerName already exists!  Updating scripts and configuring service ..."

#   # Get Home directory path and username
#   DirName=$(readlink -e /minecraft)
#   UserName=$(whoami)
#   cd /minecraft
#   cd minecraftbe
#   cd $ServerName
#   echo "Server directory is: $DirName/minecraftbe/$ServerName"

#   # Remove existing scripts
#   rm start.sh stop.sh restart.sh

#   # Download start.sh from repository
#   echo "Grabbing start.sh from repository..."
#   wget -O start.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/start.sh
#   chmod +x start.sh
#   sed -i "s:dirname:$DirName:g" start.sh
#   sed -i "s:servername:$ServerName:g" start.sh

#   # Download stop.sh from repository
#   echo "Grabbing stop.sh from repository..."
#   wget -O stop.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/stop.sh
#   chmod +x stop.sh
#   sed -i "s:dirname:$DirName:g" stop.sh
#   sed -i "s:servername:$ServerName:g" stop.sh

#   # Download restart.sh from repository
#   echo "Grabbing restart.sh from repository..."
#   wget -O restart.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/restart.sh
#   chmod +x restart.sh
#   sed -i "s:dirname:$DirName:g" restart.sh
#   sed -i "s:servername:$ServerName:g" restart.sh

#   # Update minecraft server service
#   echo "Configuring $ServerName service..."
#   sudo wget -O /etc/systemd/system/$ServerName.service https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/minecraftbe.service
#   sudo chmod +x /etc/systemd/system/$ServerName.service
#   sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/$ServerName.service
#   sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/$ServerName.service
#   sudo sed -i "s:servername:$ServerName:g" /etc/systemd/system/$ServerName.service
#   sed -i "/server-port=/c\server-port=$PortIPV4" server.properties
#   sed -i "/server-portv6=/c\server-portv6=$PortIPV6" server.properties
#   sudo systemctl daemon-reload
#   echo -n "Start Minecraft server at startup automatically (y/n)?"
#   read answer < /dev/tty
#   if [ "$answer" != "${answer#[Yy]}" ]; then
#     sudo systemctl enable $ServerName.service

#     # Automatic reboot at 4am configuration
#     echo -n "Automatically restart and backup server at 4am daily (y/n)?"
#     read answer < /dev/tty
#     if [ "$answer" != "${answer#[Yy]}" ]; then
#       croncmd="$DirName/minecraftbe/$ServerName/restart.sh"
#       cronjob="0 4 * * * $croncmd"
#       ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#       echo "Daily restart scheduled.  To change time or remove automatic restart type crontab -e"
#     fi
#   fi

#   # Setup completed
#   echo "Setup is complete.  Starting Minecraft $ServerName server..."
#   sudo systemctl start $ServerName.service

#   # Sleep for 4 seconds to give the server time to start
#   sleep 4s

#   screen -r $ServerName

#   exit 0
# fi

# # Create server directory
# echo "Creating minecraft server directory (/minecraft/minecraftbe/$ServerName)..."
# cd /minecraft
# cd minecraftbe
# mkdir $ServerName
# cd $ServerName
# mkdir downloads
# mkdir backups

# # Check CPU archtecture to see if we need to do anything special for the platform the server is running on
# echo "Getting system CPU architecture..."
# CPUArch=$(uname -m)
# echo "System Architecture: $CPUArch"
# if [[ "$CPUArch" == *"aarch"* || "$CPUArch" == *"arm"* ]]; then
#   # ARM architecture detected -- download QEMU and dependency libraries
#   echo "ARM platform detected -- installing dependencies..."
#   # Check if latest available QEMU version is at least 3.0 or higher
#   QEMUVer=$(apt-cache show qemu-user-static | grep Version | awk 'NR==1{ print $2 }' | cut -c3-3)
#   if [[ "$QEMUVer" -lt "3" ]]; then
#     echo "Available QEMU version is not high enough to emulate x86_64.  Downloading alternative..."
#     if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
#       wget http://ftp.us.debian.org/debian/pool/main/q/qemu/qemu-user-static_3.1+dfsg-8_armhf.deb
#       wget http://ftp.us.debian.org/debian/pool/main/b/binfmt-support/binfmt-support_2.2.0-2_armhf.deb
#       sudo dpkg --install binfmt*.deb
#       sudo dpkg --install qemu-user*.deb
#     elif [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
#       wget http://ftp.us.debian.org/debian/pool/main/q/qemu/qemu-user-static_3.1+dfsg-8_arm64.deb
#       wget http://ftp.us.debian.org/debian/pool/main/b/binfmt-support/binfmt-support_2.2.0-2_arm64.deb
#       sudo dpkg --install binfmt*.deb
#       sudo dpkg --install qemu-user*.deb
#     fi
#   else
#     sudo apt-get install qemu-user-static binfmt-support -y
#   fi

#   if [ -n "`which qemu-x86_64-static`" ]; then
#     echo "QEMU-x86_64-static installed successfully"
#   else
#     echo "QEMU-x86_64-static did not install successfully -- please check the above output to see what went wrong."
#     exit 1
#   fi
  
#   # Retrieve depends.zip from GitHub repository
#   wget -O depends.zip https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/depends.zip
#   unzip depends.zip
#   sudo mkdir /lib64
#   # Create soft link ld-linux-x86-64.so.2 mapped to ld-2.28.so
#   sudo ln -s /minecraft/minecraftbe/$ServerName/ld-2.28.so /lib64/ld-linux-x86-64.so.2
# fi

# # Retrieve latest version of Minecraft Bedrock dedicated server
# echo "Checking for the latest version of Minecraft Bedrock server..."
# wget -O downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
# DownloadURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)
# DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')
# echo "$DownloadURL"
# echo "$DownloadFile"

# # Download latest version of Minecraft Bedrock dedicated server
# echo "Downloading the latest version of Minecraft Bedrock server..."
# UserName=$(whoami)
# DirName=$(readlink -e /minecraft)
# wget -O "downloads/$DownloadFile" "$DownloadURL"
# unzip -o "downloads/$DownloadFile"

# # Download start.sh from repository
# echo "Grabbing start.sh from repository..."
# wget -O start.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/start.sh
# chmod +x start.sh
# sed -i "s:dirname:$DirName:g" start.sh
# sed -i "s:servername:$ServerName:g" start.sh

# # Download stop.sh from repository
# echo "Grabbing stop.sh from repository..."
# wget -O stop.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/stop.sh
# chmod +x stop.sh
# sed -i "s:dirname:$DirName:g" stop.sh
# sed -i "s:servername:$ServerName:g" stop.sh

# # Download restart.sh from repository
# echo "Grabbing restart.sh from repository..."
# wget -O restart.sh https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/restart.sh
# chmod +x restart.sh
# sed -i "s:dirname:$DirName:g" restart.sh
# sed -i "s:servername:$ServerName:g" restart.sh

# # Service configuration
# echo "Configuring Minecraft $ServerName service..."
# sudo wget -O /etc/systemd/system/$ServerName.service https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/minecraftbe.service
# sudo chmod +x /etc/systemd/system/$ServerName.service
# sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/$ServerName.service
# sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/$ServerName.service
# sudo sed -i "s:servername:$ServerName:g" /etc/systemd/system/$ServerName.service
# sed -i "/server-port=/c\server-port=$PortIPV4" server.properties
# sed -i "/server-portv6=/c\server-portv6=$PortIPV6" server.properties
# sudo systemctl daemon-reload

# echo -n "Start Minecraft server at startup automatically (y/n)?"
# read answer < /dev/tty
# if [ "$answer" != "${answer#[Yy]}" ]; then
#   sudo systemctl enable $ServerName.service

#   # Automatic reboot at 4am configuration
#   TimeZone=$(cat /etc/timezone)
#   CurrentTime=$(date)
#   echo "Your time zone is currently set to $TimeZone.  Current system time: $CurrentTime"
#   echo "You can adjust/remove the selected reboot time later by typing crontab -e or running SetupMinecraft.sh again."
#   echo -n "Automatically restart and backup server at 4am daily (y/n)?"
#   read answer < /dev/tty
#   if [ "$answer" != "${answer#[Yy]}" ]; then
#     croncmd="$DirName/minecraftbe/$ServerName/restart.sh"
#     cronjob="0 4 * * * $croncmd"
#     ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#     echo "Daily restart scheduled.  To change time or remove automatic restart type crontab -e"
#   fi
# fi

# # Finished!
# echo "Setup is complete.  Starting Minecraft server..."
# sudo systemctl start $ServerName.service

# # Wait up to 20 seconds for server to start
# StartChecks=0
# while [ $StartChecks -lt 20 ]; do
#   if screen -list | grep -q "$ServerName"; then
#     break
#   fi
#   sleep 1;
#   StartChecks=$((StartChecks+1))
# done

# # Force quit if server is still open
# if ! screen -list | grep -q "$ServerName"; then
#   echo "Minecraft server failed to start after 20 seconds."
# else
#   echo "Minecraft server has started.  Type screen -r $ServerName to view the running server!"
# fi

# # Attach to screen
# screen -r $ServerName