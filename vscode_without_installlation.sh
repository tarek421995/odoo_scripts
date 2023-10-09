#!/bin/bash
# Open VS Code as odoo16 user
echo "----- Opening VS Code as odoo16 user -----"
# Granting necessary permissions and launching VS Code as odoo16
echo "Granting permissions and launching VS Code..."
xhost +SI:localuser:odoo16
sudo -u odoo16 -i code --no-sandbox --user-data-dir="/tmp/vscode-odoo16/" /opt/odoo16 &
