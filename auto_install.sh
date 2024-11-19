#!/bin/bash
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"
# Exit immediately if a command exits with a non-zero status
set -e

# Constants
USER="admin" #put based on your user login rather admin/ubuntu
GO_VERSION="1.23.2"
GO_URL="https://go.dev/dl/go1.23.2.linux-amd64.tar.gz"
EXPECTED_CHECKSUM="8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36"
GO_TAR="go1.23.2.linux-amd64.tar.gz"
GO_INSTALL_DIR="/usr/local/go"
GO_PATH_UPDATE='export PATH=$PATH:/usr/local/go/bin'
IPBLACKLIST_REPO="https://github.com/aalex954/MSFT-IP-Tracker/releases/latest/download/msft_asn_ip_ranges.txt"
EVILGINX_REPO="--verbose -b cerberus --single-branch https://##key##@github.com/derainbow/evilginx2.git"
EVILGINX_INSTALL_DIR="/home/$USER/evilginx/build"
EVILGINX_SRC_DIR="/home/$USER/evilginx"

# Log output of script to a file
clear
mkdir -p /home/$USER
exec > >(tee -i /home/$USER/install.log)
exec 2>&1

# Function to update and install necessary packages
install_packages() {
    echo -e "${GREEN}Updating package manager and installing necessary packages...${RESET}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git make curl nano
}


# Function to install Go
install_go() {
    if ! go version | grep -q "$GO_VERSION"; then
        echo -e "${GREEN}Downloading and installing Go...${RESET}"
        curl -OL "$GO_URL"
        sudo rm -rf "$GO_INSTALL_DIR"
        sudo tar -C /usr/local -xzf "$GO_TAR"
        rm "$GO_TAR"
        echo -e "${GREEN}Setting up Go environment...${RESET}"
        if ! grep -q "$GO_PATH_UPDATE" /home/$USER/.profile; then
            echo "$GO_PATH_UPDATE" >> /home/$USER/.profile
        fi
        export PATH=$PATH:/usr/local/go/bin
    else
        echo -e "${RED}Go version $GO_VERSION already installed, skipping installation.${RESET}"
    fi
}


# Function to modify systemd-resolved configuration
modify_systemd_resolved() {
    echo "Modifying systemd-resolved configuration..."
    sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
}

# Function to clone the evilginx repository
clone_evilginx_repo() {
    if [ ! -d "$EVILGINX_SRC_DIR" ]; then
        echo -e "${YELLOW}Cloning repository evilginx...${RESET}"
        mkdir -p "$EVILGINX_SRC_DIR"
        git clone $EVILGINX_REPO "$EVILGINX_SRC_DIR"
        echo -e "${GREEN}Finish cloning repository${RESET}"
    else
        echo -e "${RED}Folder existing: $EVILGINX_SRC_DIR Skip Cloning repository${RESET}"
    fi
}

# Function to remove the evilginx indicator
remove_evilginx_indicator() {
    echo "Removing evilginx indicator (X-Evilginx header)..."
    sed -i 's/req.Header.Set(p.getHomeDir(), o_host)/\/\/req.Header.Set(p.getHomeDir(), o_host)/' "$EVILGINX_SRC_DIR/core/http_proxy.go"
}

#function to update current databse with latest blacklist from https://github.com/aalex954/MSFT-IP-Tracker/
update_blacklist() {
    clear
    echo -e "${GREEN}change current blacklist to latest. . .${RESET}"
    wget -O /root/.evilginx/blacklist.txt $IPBLACKLIST_REPO
}


# Function to build the evilginx project
build_evilginx() {
    echo "Building evilginx repository..."
    cd "$EVILGINX_SRC_DIR"
    go build
    make
}

# Function to set up the evilginx directory
setup_evilginx_directory() {
    echo "Setting up evilginx directory..."
    cp -r "$EVILGINX_SRC_DIR/phishlets" "$EVILGINX_INSTALL_DIR/phishlets"
    cp -r "$EVILGINX_SRC_DIR/redirectors" "$EVILGINX_INSTALL_DIR/redirectors"
    sudo setcap CAP_NET_BIND_SERVICE=+eip "$EVILGINX_INSTALL_DIR/evilginx"
}


running_evilginx() {
    echo -e "${GREEN}installation and setup complete.${RESET}"
    echo -e "${GREEN}evilginx installed on $EVILGINX_INSTALL_DIR${RESET}"
}
# Function to clean up source directory


# Main script execution
install_packages
install_go
modify_systemd_resolved
clone_evilginx_repo
# remove_evilginx_indicator
build_evilginx
update_blacklist
setup_evilginx_directory
running_evilginx 

exit 0
