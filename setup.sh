#!/bin/bash
set -e  # Exit immediately on error

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
sudo apt install -y software-properties-common apt-transport-https wget gpg

wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update -y
sudo apt install code -y

# -------------------------------
# Step 6: Install Python
# -------------------------------
sudo apt install -y python3 python3-pip

# -------------------------------
# Step 7: Install Microsoft Edge
# -------------------------------
echo "Adding Microsoft GPG key..."
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
rm microsoft.gpg

echo "Adding Microsoft Edge repository..."
echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

echo "Updating package list..."
sudo apt update

echo "Installing Microsoft Edge (Stable)..."
sudo apt install -y microsoft-edge-stable

# -------------------------------
# 8 : Install Postman
# -------------------------------
sudo snap install postman

# -------------------------------
# 9: Install GitHub Desktop
# -------------------------------
sudo snap install github-desktop --classic

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
