#!/bin/sh

# Check if common profile files exist and source them
BASH_PROFILE=$HOME'/.bash_profile'
if [ -f $BASH_PROFILE ]; then
    echo "Sourcing $BASH_PROFILE."
    . $BASH_PROFILE
else
   echo "$BASH_PROFILE does not exist. Skipping file."
fi
BASHRC=$HOME'/.bashrc'
if [ -f $BASHRC ]; then
    echo "Sourcing $BASHRC."
    . $BASHRC
else
   echo "$BASHRC does not exist. Skipping file."
fi
ZSHRC=$HOME'/.zshrc'
if [ -f $ZSHRC ]; then
    echo "Sourcing $ZSHRC."
    . $ZSHRC
else
   echo "$ZSHRC does not exist. Skipping file."
fi
ZPROFILE=$HOME'/.zprofile'
if [ -f $ZPROFILE ]; then
    echo "Sourcing $ZPROFILE."
    . $ZPROFILE
else
   echo "$ZPROFILE does not exist. Skipping file."
fi
PROFILE=$HOME'/.profile'
if [ -f $PROFILE ]; then
    echo "Sourcing $PROFILE."
    . $PROFILE
else
   echo "$PROFILE does not exist. Skipping file."
fi
NVM_SH=$HOME'/.nvm/nvm.sh'
if [ -f $NVM_SH ]; then
    echo "Sourcing $NVM_SH."
    . $NVM_SH
else
   echo "$NVM_SH does not exist. Skipping file."
fi

# homebridge directory location for check below
HB_DIR=$HOME'/.homebridge'

reinstall_homebridge() {
    # Handle Homebridge Installation
    if [ -d "$HB_DIR" ]; then
        echo "Reinstalling Homebridge service."
        sudo hb-service rebuild --all
        sudo hb-service install
        sudo hb-service start
    fi
}

# current local version
CURRENT="$(nvm current)"
# latest LTS
LTS="$(nvm version-remote --lts)"

# Check if update is needed
if [ "$CURRENT" == "$LTS" ]; then
    echo "Current version $CURRENT matches latest $LTS."
    echo "No update needed."
    exit 0
else
    # Handle Homebridge Installation
    if [ -d "$HB_DIR" ]; then
        echo "Homebridge installation found."
        echo "Stopping Homebridge during update."
        sudo hb-service stop
        sudo hb-service uninstall
    fi
    
    # Only install new version without migrating packages
    echo "Installing new version: $LTS."
    nvm install "lts/*"
    
    # Test the new node version by running a simple command
    # 'node -v' should print out the version number of the node installation
    node -v > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error with the new node version. Rolling back to $CURRENT."
        nvm uninstall lts/*
        nvm use $CURRENT
    else
        # Now that new version is confirmed working, migrate packages
        echo "Migrating packages from $CURRENT to $LTS."
        nvm reinstall-packages $CURRENT

        # cleanup old install
        nvm uninstall $CURRENT
    fi
    reinstall_homebridge
fi

exit 0
