#!/bin/sh

# -----------------------
# FUNCTIONS
# -----------------------

# Function to source a file if it exists
source_if_exists() {
    if [ -f "$1" ]; then
        echo "Sourcing $1."
        . "$1"
    else
        echo "$1 does not exist. Skipping file."
    fi
}

# Function to reinstall Homebridge
reinstall_homebridge() {
    if [ -d "$HB_DIR" ]; then
        echo "Reinstalling Homebridge service."
        sudo hb-service rebuild --all
        sudo hb-service install
        sudo hb-service start
    fi
}

# Function to upgrade to the latest version of the current major version line
upgrade_within_major() {
    local CURRENT_MAJOR=$(echo "$1" | cut -d '.' -f 1)
    local LATEST_WITHIN_MAJOR=$(nvm ls-remote | grep -o "${CURRENT_MAJOR}\.[0-9]*\.[0-9]*" | tail -n 1)

    if [ "$LATEST_WITHIN_MAJOR" == "$CURRENT" ]; then
        echo "You are already using the latest version within the $CURRENT_MAJOR.x.x line."
        return 0
    fi

    echo "Upgrading to the latest $CURRENT_MAJOR.x.x: $LATEST_WITHIN_MAJOR."

    nvm install "$LATEST_WITHIN_MAJOR"
    node -v > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error with the new node version within the same major. Rolling back to $CURRENT."
        nvm uninstall "$LATEST_WITHIN_MAJOR"
        nvm use "$CURRENT"
    else
        echo "Migrating packages from $CURRENT to $LATEST_WITHIN_MAJOR."
        nvm reinstall-packages "$CURRENT"
        nvm uninstall "$CURRENT"
    fi
}

# -----------------------
# MAIN SCRIPT
# -----------------------

# Check if common profile files exist and source them
source_if_exists "$HOME/.bash_profile"
source_if_exists "$HOME/.bashrc"
source_if_exists "$HOME/.zshrc"
source_if_exists "$HOME/.zprofile"
source_if_exists "$HOME/.profile"
source_if_exists "$HOME/.nvm/nvm.sh"

# homebridge directory location for check below
HB_DIR="$HOME/.homebridge"

# current local version
CURRENT="$(nvm current)"
# latest LTS
LTS="$(nvm version-remote --lts)"

# Check if update is needed
if [ "$CURRENT" == "$LTS" ]; then
    echo "Current version $CURRENT matches latest $LTS."
    echo "No update needed."
else
    if [ -d "$HB_DIR" ]; then
        echo "Homebridge installation found."
        echo "Stopping Homebridge during update."
        sudo hb-service stop
        sudo hb-service uninstall
    fi

    echo "Installing new LTS version: $LTS."
    nvm install "lts/*"
    node -v > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error with the new LTS node version. Rolling back to $CURRENT."
        nvm uninstall "lts/*"
        nvm use "$CURRENT"
        # Perform upgrade within the same major version
        upgrade_within_major "$CURRENT"
    else
        echo "Migrating packages from $CURRENT to $LTS."
        nvm reinstall-packages "$CURRENT"
        nvm uninstall "$CURRENT"
    fi

    reinstall_homebridge
fi

exit 0
