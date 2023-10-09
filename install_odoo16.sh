#!/bin/bash
# find . -type f ! -name '__init__.py' -exec echo -e "\n====== {} ======\n" \; -exec cat {} \;

# Provide feedback about each step
echo "----- Updating and Upgrading System Packages -----"
sudo apt update && sudo apt upgrade -y

echo "----- Creating System User for Odoo -----"
sudo useradd -m -d /opt/odoo16 -U -r -s /bin/bash odoo16

echo "----- Installing Dependencies for Odoo -----"
sudo apt install -y build-essential wget git python3-pip python3-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libsasl2-dev python3-setuptools libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libopenjp2-7-dev

echo "----- Installing and Configuring PostgreSQL -----"
sudo apt install -y postgresql
sudo su - postgres -c "createuser -s odoo16"

echo "----- Installing Wkhtmltopdf and Checking its Version -----"
sudo apt install -y wkhtmltopdf
wkhtmltopdf --version

echo "----- Installing Git -----"
sudo apt-get install -y git

echo "----- Cloning Odoo and Setting Up the Virtual Environment -----"
sudo su - odoo16 <<'EOF'
git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 odoo16
python3 -m venv odoo16-venv
source odoo16-venv/bin/activate
pip3 install wheel
pip3 install -r odoo16/requirements.txt
deactivate
mkdir /opt/odoo16/odoo16/custom
EOF

echo "----- Creating Configuration File for Odoo -----"
echo "[options]
admin_passwd = admin
db_host = False
db_port = False
db_user = odoo16
db_password = False
addons_path = /opt/odoo16/odoo16/addons,/opt/odoo16/odoo16/custom
xmlrpc_port = 8016" | sudo tee /etc/odoo16.conf

echo "----- Setting Up a System Service to Run Odoo -----"
echo "[Unit]
Description=Odoo16
Requires=postgresql.service
After=network.target postgresql.service
[Service]
Type=simple
SyslogIdentifier=odoo16
PermissionsStartOnly=true
User=odoo16
Group=odoo16
ExecStart=/opt/odoo16/odoo16-venv/bin/python3 /opt/odoo16/odoo16/odoo-bin -c /etc/odoo16.conf
StandardOutput=journal+console
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/odoo16.service

echo "----- Reloading SystemD and Starting Odoo Service -----"
sudo systemctl daemon-reload
sudo systemctl start odoo16
sudo systemctl status odoo16

echo "----- Granting sudo Privileges to odoo16 User -----"
echo "odoo16    ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

# Provide final feedback to the user
echo "----- Script Execution Completed -----"
sudo journalctl -u odoo16 -f