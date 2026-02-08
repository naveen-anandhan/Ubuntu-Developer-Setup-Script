#!/bin/bash
set -e  # Exit immediately on error
# Emergency cleanup of old VS Code repo definitions
sudo rm -f /etc/apt/sources.list.d/vscode.*

# ------------------------------------------
# Setup Script: VS Code, MySQL, Python, Edge, git desktop , docker, postman.
# ------------------------------------------

#i have update step 4 if not worked try download and uncomment step 4 then run again
# step 1: First download MySQL Workbench installer
     #   Path : https://dev.mysql.com/downloads/workbench/
     #    EG:   mysql-workbench-community_8.0.43-1ubuntu22.04_amd64.deb

#step 2: chmod +x setup.sh
#step 3: ./setup.sh
#step 4: create password for MySQL
# Script only ask for create new Password for MySQL workbench other then that every thing automatic
# After that it will reboot you have every thing

# -------------------------------
# Step 1: Update system packages
# -------------------------------
# Recover if any package configuration was interrupted earlier
sudo dpkg --configure -a || true


sudo apt update -y
sudo apt upgrade -y

# -------------------------------
# Step 2: Install MySQL Server
# -------------------------------
sudo apt install mysql-server -y

# Ensure MySQL service is running (usually already started)
sudo systemctl start mysql || true

# -------------------------------
# Step 3: Configure MySQL user
# -------------------------------
# WARNING: Storing passwords in plaintext is not recommended.
# Replace 'Naveen' and 'Password' if needed.

if sudo mysql -e "SELECT 1 FROM mysql.user WHERE user='Naveen'" | grep -q 1; then
    echo "MySQL user already exists. Skipping password setup."
else
    read -sp "Enter MySQL password for Naveen: " MYSQL_PASS
    echo ""

    sudo mysql -e "CREATE USER 'Naveen'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'Naveen'@'localhost' WITH GRANT OPTION;"
    sudo mysql -e "FLUSH PRIVILEGES;"
fi


# special case if i want creart user to access my dbs
                #CREATE USER 'ravi'@'192.168.1.50' IDENTIFIED BY 'SomeStrongPassword';
                #GRANT ALL PRIVILEGES ON *.* TO 'ravi'@'192.168.1.50';
                #FLUSH PRIVILEGES;



# Connection Name: Naveen or Practice
# Hostname: localhost or 127.0.0.1
#  Port: 3306
#  Username: Naveen
#  Password: Password 



# -------------------------------
# Step 4: Install MySQL Workbench
# ------------------------------- 

# -------------------------------
# Step 4: Install MySQL Workbench
# -------------------------------
sudo apt install -y mysql-workbench-community


#cd ~/Downloads/

# Check for the .deb file before installing
#if ls mysql-workbench-community*.deb 1> /dev/null 2>&1; then
#    sudo apt install ./mysql-workbench-community*.deb -y
#else
#    echo "MySQL Workbench .deb file not found in ~/Downloads. Skipping..."
#fi

# -------------------------------
# Step 5: Install VS Code
# -------------------------------

echo "Cleaning old VS Code repository definitions..."
#sudo rm -f /etc/apt/sources.list.d/vscode.*
sudo rm -f /usr/share/keyrings/microsoft.gpg 2>/dev/null || true

sudo apt install -y software-properties-common apt-transport-https wget gpg

echo "Setting up VS Code repository..."

# Add Microsoft key (only if missing)
if [ ! -f /usr/share/keyrings/packages.microsoft.gpg ]; then
  wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | \
  sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
fi

# Add repo
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code


# -------------------------------
# Step 6: Install Python
# -------------------------------
sudo apt install -y python3 python3-pip

# -------------------------------
# Step 7: Install Microsoft Edge
# -------------------------------
echo "Setting up Microsoft Edge repository..."

# Add Microsoft key only if it doesn't already exist
if [ ! -f /usr/share/keyrings/microsoft-edge.gpg ]; then
  wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | \
  sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
fi

# Add / refresh repo
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
  sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

sudo apt update
sudo apt install -y microsoft-edge-stable

# -------------------------------
# 8 : Install Postman
# -------------------------------
sudo snap install postman

# -------------------------------
# 9: Install GitHub Desktop (Shiftkey)
# -------------------------------
echo "Setting up GitHub Desktop repository..."

# Add key only if missing
if [ ! -f /usr/share/keyrings/shiftkey-packages.gpg ]; then
  wget -qO - https://apt.packages.shiftkey.dev/gpg.key | \
  gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
fi

# Add repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu any main" | \
  sudo tee /etc/apt/sources.list.d/shiftkey-packages.list > /dev/null

sudo apt update
sudo apt install -y github-desktop

# -------------------------------
# 10: Install Docker
# -------------------------------
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# allow current user to run docker without sudo
sudo usermod -aG docker $USER


# -------------------------------
# Step 8: Confirmation Messages
# -------------------------------
echo "------------------------------------------------"
echo "✅ Installation complete!"
echo "🛠 MySQL Server and Workbench installed."
echo "📝 VS Code installed."
echo "🐍 Python installed."
echo "🌐 Microsoft Edge installed."
echo ""
echo "GitHub desktop installed"
echo "Postman installed"
echo "Docker installed"
echo "------------------------------------------------"

echo ""
echo "🔁 System will reboot in 10 seconds to finalize Docker setup..."
sleep 10
sudo reboot
