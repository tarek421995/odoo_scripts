#!/bin/bash

# Feedback: Starting script execution
echo "----- Starting script execution -----"

# 1. Create restart_odoo_on_change.sh script
echo "----- Creating restart_odoo_on_change.sh script -----"
# Installing necessary tools
echo "Installing inotify-tools..."
sudo apt-get install inotify-tools

# Writing the script to a file
echo "Writing restart script content..."
cat > restart_odoo_on_change.sh <<EOL
#!/bin/bash

DIRECTORY_TO_OBSERVE="/opt/odoo16"
while true; do
  change=\$(inotifywait -r -e close_write,moved_to,create "\$DIRECTORY_TO_OBSERVE")
  change=\${change#"\$DIRECTORY_TO_OBSERVE"}
  echo "\$change detected. Restarting Odoo..."
  sudo systemctl restart odoo16
  echo "Odoo restarted!"
done
EOL

# Making the script executable
echo "Making the script executable..."
chmod +x restart_odoo_on_change.sh
chmod +x vscode_without_installlation

# 2. Change password for odoo16 user
echo "----- Changing password for odoo16 user -----"
echo "Updating odoo16's password..."
echo "odoo16:tarek" | sudo chpasswd

# 3. Install VS Code
echo "----- Installing Visual Studio Code -----"
# Updating and preparing for the VS Code installation
echo "Updating system and preparing for VS Code installation..."
sudo apt update
sudo apt install -y software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update

# Installing VS Code
echo "Installing VS Code..."
sudo apt install -y code

# 4. Open VS Code as odoo16 user
echo "----- Opening VS Code as odoo16 user -----"
# Granting necessary permissions and launching VS Code as odoo16
echo "Granting permissions and launching VS Code..."
xhost +SI:localuser:odoo16
sudo -u odoo16 -i code --no-sandbox --user-data-dir="/tmp/vscode-odoo16/" &

# Feedback: Script execution completed
echo "----- Script Execution Completed -----"
