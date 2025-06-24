#!/bin/bash

echo "[*] Starting installation process..."

# === Check for dependencies ===
read -p "Do you want to install dependencies? [y/n]: " INSTALL_DEPS
if [[ "$INSTALL_DEPS" == "y" ]]; then
    echo "[*] Checking dependencies..."
    if ! command -v mysql &> /dev/null; then
        echo "[!] mysql-client is not installed. Installing..."
        sudo apt-get update && sudo apt-get install -y mysql-client || { echo "[!] Failed to install mysql-client."; exit 1; }
    else
        echo "[✓] mysql-client is already installed."
    fi

    if ! command -v python3 &> /dev/null; then
        echo "[!] python3 is not installed. Installing..."
        sudo apt-get update && sudo apt-get install -y python3 || { echo "[!] Failed to install python3."; exit 1; }
    else
        echo "[✓] python3 is already installed."
    fi
else
    echo "[*] Skipping dependency installation."
fi

# === Validate MySQL Host IP ===
read -p "Enter MySQL Host IP: " MYSQL_HOST
if [[ ! "$MYSQL_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[!] Invalid IP address format. Please enter a valid IP."
    exit 1
fi

# === Set up environment variables ===
echo "[*] Setting up environment variables..."
read -p "Enter MySQL Username [default: root]: " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-root}
read -s -p "Enter MySQL Password (leave blank if none): " MYSQL_PASSWORD
echo

echo "export MYSQL_HOST=\"$MYSQL_HOST\"" >> ~/.bashrc
echo "export MYSQL_USER=\"$MYSQL_USER\"" >> ~/.bashrc
echo "export MYSQL_PASSWORD=\"$MYSQL_PASSWORD\"" >> ~/.bashrc
source ~/.bashrc

# === Enable stealth mode ===
read -p "Enable stealth mode? [y/n]: " STEALTH_MODE
if [[ "$STEALTH_MODE" == "y" ]]; then
    echo "export STEALTH_MODE=true" >> ~/.bashrc
    echo "[*] Stealth mode enabled."
fi

# === Ensure script permissions ===
echo "[*] Setting executable permissions for the main script..."
chmod +x src/mySQL_Extractor.sh || { echo "[!] Failed to set permissions."; exit 1; }

# === Create necessary directories ===
echo "[*] Creating necessary directories..."
mkdir -p results || { echo "[!] Failed to create results directory."; exit 1; }
mkdir -p csv-dump-$(date +%Y%m%d-%H%M%S) || { echo "[!] Failed to create csv-dump directory."; exit 1; }

# === Final message ===
echo "[✓] Installation complete! You can now run the script using:"
echo "bash src/mySQL_Extractor.sh"