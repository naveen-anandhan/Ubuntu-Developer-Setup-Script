#!/bin/bash
set -e

# ------------------------------------------
# Setup Script: VS Code, MySQL, Python, Edge, git-desktop, docker, postman.
# ------------------------------------------

#I have update step 3 if not worked try download and uncomment step 4 then run again if worked ignore step 1 start at step 2
# step 1: First download MySQL Workbench installer
#   Path : https://dev.mysql.com/downloads/workbench/
#   EG:   mysql-workbench-community_8.0.43-1ubuntu22.04_amd64.deb

#step 2: chmod +x setup.sh
#step 3: ./setup.sh
#step 4: create password for MySQL
# Script only ask for create new Password for MySQL workbench other then that every thing automatic
# After that it will reboot you have every thing

echo "🚀 Starting machine setup..."
export DEBIAN_FRONTEND=noninteractive


MYSQL_PASS=""

if command -v mysql >/dev/null 2>&1 && \
   sudo mysql -e "SELECT 1 FROM mysql.user WHERE user='Naveen'" >/dev/null 2>&1; then

    echo "✅ MySQL user already exists. Password not needed."
else
    read -sp "Enter MySQL password for Naveen: " MYSQL_PASS
    echo ""
fi

# ------------------------------------------------
# Step 1: System Fix & Update
# ------------------------------------------------
sudo dpkg --configure -a || true
sudo apt update -y
sudo apt upgrade -y
sudo systemctl daemon-reload

# ------------------------------------------------
# Step 2: MySQL Server & User
# ------------------------------------------------
sudo apt install -y mysql-server
sudo systemctl start mysql || true

USER_EXISTS=$(sudo mysql -Nse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user='Naveen' AND host='localhost');")

if [ "$USER_EXISTS" -eq 1 ]; then
    echo "✅ MySQL user 'Naveen' already exists."
else
    echo "👤 Creating MySQL user..."
    sudo mysql -e "CREATE USER 'Naveen'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'Naveen'@'localhost' WITH GRANT OPTION;"
    sudo mysql -e "FLUSH PRIVILEGES;"
fi
#-----------Manual step 3 for downloaded mysql-workbench------------

#-- after download the mysql-workbench uncomment below and run it again

#cd ~/Downloads/

#if ls mysql-workbench-community*.deb 1> /dev/null 2>&1; then
#    sudo apt install ./mysql-workbench-community*.deb -y
#else
#    echo "MySQL Workbench .deb file not found in ~/Downloads. Skipping..."
#fi

# ------------------------------------------------
# Step 3: MySQL Workbench
# ------------------------------------------------
echo "Installing MySQL Workbench..."
sudo snap install mysql-workbench-community || true

# ------------------------------------------------
# Step 4: VS Code
# ------------------------------------------------
echo "Installing VS Code..."
sudo rm -f /etc/apt/sources.list.d/vscode.*

if [ ! -f /usr/share/keyrings/packages.microsoft.gpg ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
fi

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code

# ------------------------------------------------
# Step 5: Microsoft Edge
# ------------------------------------------------
echo "Installing Microsoft Edge..."
sudo rm -f /etc/apt/sources.list.d/microsoft-edge.list

if [ ! -f /usr/share/keyrings/microsoft-edge.gpg ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
fi

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

sudo apt update
sudo apt install -y microsoft-edge-stable

# ------------------------------------------------
# Step 6: GitHub Desktop
# ------------------------------------------------
echo "Installing GitHub Desktop..."
if ! dpkg -l | grep -q github-desktop; then
    LATEST_URL=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest | \
        grep browser_download_url | grep linux-amd64 | grep .deb | head -n 1 | cut -d '"' -f 4)

    if [ -n "$LATEST_URL" ]; then
        wget -q -O /tmp/github-desktop.deb "$LATEST_URL"
        sudo apt install -y /tmp/github-desktop.deb
        rm /tmp/github-desktop.deb
    else
        echo "⚠️ Could not fetch GitHub Desktop."
    fi
else
    echo "✅ GitHub Desktop already installed."
fi

# ------------------------------------------------
# Step 7: Docker Engine + Desktop
# ------------------------------------------------
echo "Installing Docker..."
sudo rm -f /etc/apt/sources.list.d/docker.list

sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

[ ! -f /etc/apt/keyrings/docker.gpg ] && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing Docker Desktop..."
wget -q -O /tmp/docker-desktop.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo apt install -y /tmp/docker-desktop.deb
rm /tmp/docker-desktop.deb

sudo usermod -aG docker $USER

# ------------------------------------------------
# Step 8: Python Essentials
# ------------------------------------------------
sudo apt install -y python3 python3-pip python3-venv

# ------------------------------------------------
# Final Polish
# ------------------------------------------------
sudo snap install postman || true
sudo apt autoremove -y

# -------------------------------
# Step 8: Confirmation Messages
# -------------------------------
echo "------------------------------------------------"
echo "✅ Installation complete!"
echo "🛠 MySQL Server and Workbench installed."
echo "📝 VS Code installed."
echo "🐍 Python installed."
echo "🌐 Microsoft Edge installed."
echo "GitHub desktop installed"
echo "Postman installed"
echo "Docker installed"
echo "------------------------------------------------"

echo ""
echo "🔁 System will reboot in 10 seconds to finalize Docker setup..."
sleep 10
sudo reboot
