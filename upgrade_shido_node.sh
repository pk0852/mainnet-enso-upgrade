#!/bin/bash

# Check if the script is run as root
#if [ "$(id -u)" != "0" ]; then
#  echo "This script must be run as root or with sudo." 1>&2
#  exit 1
#fi

current_path=$(pwd)

# replace cosmwasmvm with cosmwasmvm v2.1.4
sudo rm -rf /usr/lib/libwasmvm.x86_64.so
sudo cp "$current_path/libwasmvm.x86_64.so" /usr/lib

# Get OS and version
OS=$(awk -F= '/^NAME=/{print $2}' /etc/os-release | tr -d '"' | awk '{print $1}')
VERSION=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release | tr -d '"' | awk '{print $1}')
wget https://github.com/ShidoGlobal/testnet-enso-upgrade/releases/download/ubuntu${VERSION}/shidod
chmod u+x shidod
# Define the binary
BINARY="shidod"

# Set dedicated home directory for the shidod instance
HOMEDIR="/data/.tmp-shidod"
echo "export DAEMON_NAME=shidod" >> ~/.profile
echo "export DAEMON_HOME=$HOMEDIR" >> ~/.profile
source ~/.profile

echo "DAEMON_HOME is now: $DAEMON_HOME"
echo "DAEMON_NAME is now: $DAEMON_NAME"

# Check if the OS is Ubuntu and the version is either 20.04 or 22.04
if [ "$OS" = "Ubuntu" ] && { [ "$VERSION" = "20.04" ] || [ "$VERSION" = "22.04" ]; }; then

  # Make the new binary executable and register it with Cosmovisor
  sudo chmod u+x "$current_path/ubuntu${VERSION}build/$BINARY"
  cosmovisor add-upgrade enso "$current_path/ubuntu${VERSION}build/$BINARY"
  echo "Upgrade module enso created."
  sudo chmod u+x "$HOMEDIR/cosmovisor/upgrades/enso/bin/shidod

else
  echo "Please check the OS version support; at this time, only Ubuntu 20.04 and 22.04 are supported."
  exit 1
fi
