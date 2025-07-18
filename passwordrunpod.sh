#!/bin/bash

# Runpod SSH Setup Script with Password Authentication
# Repository: https://github.com/justinwlin/Runpod-SSH-Password
# Usage: curl -sSL https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/setup_ssh.sh | bash

# Function to print in color
print_color() {
    COLOR=$1
    TEXT=$2
    case $COLOR in
        "green") echo -e "\e[32m$TEXT\e[0m" ;;
        "red") echo -e "\e[31m$TEXT\e[0m" ;;
        "yellow") echo -e "\e[33m$TEXT\e[0m" ;;
        "blue") echo -e "\e[34m$TEXT\e[0m" ;;
        *) echo "$TEXT" ;;
    esac
}

# Function to prompt for password
get_password() {
    while true; do
        print_color "blue" "Enter a password for root user:"
        read -s root_password
        echo
        
        print_color "blue" "Confirm password:"
        read -s confirm_password
        echo
        
        if [ "$root_password" = "$confirm_password" ]; then
            print_color "green" "Password confirmed successfully."
            break
        else
            print_color "red" "Passwords do not match. Please try again."
        fi
    done
}

# Check for OS Type
print_color "blue" "Detecting Linux Distribution..."
os_info=$(cat /etc/*release)
print_color "yellow" "OS Detected: $os_info"

# Check for SSH Server and install if necessary
if ! command -v sshd >/dev/null 2>&1; then
    print_color "yellow" "SSH server not found. Installing..."
    if [[ $os_info == *"debian"* || $os_info == *"ubuntu"* ]]; then
        apt-get update && apt-get install -y openssh-server
    elif [[ $os_info == *"redhat"* || $os_info == *"centos"* ]]; then
        yum install -y openssh-server
    else
        print_color "red" "Unsupported Linux distribution for automatic SSH installation."
        exit 1
    fi
    print_color "green" "SSH Server Installed Successfully."
else
    print_color "green" "SSH Server is already installed."
fi

# Configure SSH to allow root login
print_color "blue" "Configuring SSH to allow root login with a password..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart sshd || systemctl restart ssh
else
    service ssh restart || service sshd restart
fi
print_color "green" "SSH Configuration Updated."

# Get custom password from user
get_password

# Set the custom password for root
print_color "blue" "Setting custom password for root..."
echo "root:$root_password" | chpasswd

# Create workspace directory if it doesn't exist
mkdir -p /workspace

# Save password to file
echo $root_password > /workspace/root_password.txt
print_color "green" "Root password set and saved in /workspace/root_password.txt"

# Check if environment variables are set
print_color "blue" "Checking environment variables..."
if [ -z "$RUNPOD_PUBLIC_IP" ] || [ -z "$RUNPOD_TCP_PORT_22" ]; then
    print_color "red" "Environment variables RUNPOD_PUBLIC_IP or RUNPOD_TCP_PORT_22 are missing."
    print_color "yellow" "This script is designed to run on Runpod instances."
    exit 1
fi
print_color "green" "Environment variables are set."

# Create connection script for Windows (.bat)
print_color "blue" "Creating connection script for Windows..."
cat > /workspace/connect_windows.bat << EOL
@echo off
echo ========================================
echo SSH CONNECTION TO RUNPOD
echo ========================================
echo Root password: $root_password
echo.
echo To connect via SSH:
echo ssh root@$RUNPOD_PUBLIC_IP -p $RUNPOD_TCP_PORT_22
echo.
echo ========================================
echo FILE TRANSFER EXAMPLES (SCP)
echo ========================================
echo.
echo Copy file TO pod:
echo scp -P $RUNPOD_TCP_PORT_22 yourfile.txt root@$RUNPOD_PUBLIC_IP:/workspace/
echo.
echo Copy file FROM pod:
echo scp -P $RUNPOD_TCP_PORT_22 root@$RUNPOD_PUBLIC_IP:/workspace/yourfile.txt .
echo.
echo Copy entire folder TO pod:
echo scp -P $RUNPOD_TCP_PORT_22 -r yourfolder root@$RUNPOD_PUBLIC_IP:/workspace/
echo ========================================
pause
EOL
print_color "green" "Windows connection script created in /workspace/connect_windows.bat"

# Create connection script for Linux/Mac (.sh)
print_color "blue" "Creating connection script for Linux/Mac..."
cat > /workspace/connect_linux.sh << 'EOL'
#!/bin/bash
echo '========================================'
echo 'SSH CONNECTION TO RUNPOD'
echo '========================================'
echo "Root password: $root_password"
echo ''
echo 'To connect via SSH:'
echo "ssh root@$RUNPOD_PUBLIC_IP -p $RUNPOD_TCP_PORT_22"
echo ''
echo '========================================'
echo 'FILE TRANSFER EXAMPLES (SCP)'
echo '========================================'
echo ''
echo 'Copy file TO pod:'
echo "scp -P $RUNPOD_TCP_PORT_22 yourfile.txt root@$RUNPOD_PUBLIC_IP:/workspace/"
echo ''
echo 'Copy file FROM pod:'
echo "scp -P $RUNPOD_TCP_PORT_22 root@$RUNPOD_PUBLIC_IP:/workspace/yourfile.txt ."
echo ''
echo 'Copy entire folder TO pod:'
echo "scp -P $RUNPOD_TCP_PORT_22 -r yourfolder root@$RUNPOD_PUBLIC_IP:/workspace/"
echo '========================================'
EOL

# Make the script use the actual values
sed -i "s/\$root_password/$root_password/g" /workspace/connect_linux.sh
sed -i "s/\$RUNPOD_PUBLIC_IP/$RUNPOD_PUBLIC_IP/g" /workspace/connect_linux.sh
sed -i "s/\$RUNPOD_TCP_PORT_22/$RUNPOD_TCP_PORT_22/g" /workspace/connect_linux.sh

chmod +x /workspace/connect_linux.sh
print_color "green" "Linux/Mac connection script created in /workspace/connect_linux.sh"

# Display connection information
echo ""
print_color "green" "========================================" 
print_color "green" "SETUP COMPLETED SUCCESSFULLY!"
print_color "green" "========================================"
echo ""
print_color "yellow" "SSH CONNECTION DETAILS:"
print_color "yellow" "========================================"
print_color "blue" "Connect using:"
echo "ssh root@$RUNPOD_PUBLIC_IP -p $RUNPOD_TCP_PORT_22"
echo ""
print_color "blue" "Password: $root_password"
echo ""
print_color "yellow" "========================================"
print_color "yellow" "FILE TRANSFER EXAMPLES (SCP):"
print_color "yellow" "========================================"
echo ""
print_color "blue" "Copy file TO pod:"
echo "scp -P $RUNPOD_TCP_PORT_22 yourfile.txt root@$RUNPOD_PUBLIC_IP:/workspace/"
echo ""
print_color "blue" "Copy file FROM pod:"
echo "scp -P $RUNPOD_TCP_PORT_22 root@$RUNPOD_PUBLIC_IP:/workspace/yourfile.txt ."
echo ""
print_color "blue" "Copy entire folder TO pod:"
echo "scp -P $RUNPOD_TCP_PORT_22 -r yourfolder root@$RUNPOD_PUBLIC_IP:/workspace/"
echo ""
print_color "green" "Connection scripts saved in:"
print_color "green" "- /workspace/connect_windows.bat (for Windows)"
print_color "green" "- /workspace/connect_linux.sh (for Linux/Mac)"
echo ""
print_color "yellow" "========================================"
