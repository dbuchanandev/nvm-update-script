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

# current local version
CURRENT="$(nvm current)"
# latest LTS
LTS="$(nvm version-remote --lts)"
# Check if update is needed
if [ "$CURRENT" == "$LTS" ]; then
    # exit
    echo ""
    echo "Current version $CURRENT matches latest $LTS."
    echo "No update needed."
    exit 0
else
    # run update
    echo "Updating from $CURRENT to $LTS."
    # Uncomment if Homebridge is installed
    # sudo hb-service stop
    # sudo hb-service uninstall
    
    # update and reinstall packages
    nvm install "lts/*" --reinstall-packages-from=$CURRENT
    
    # Uncomment if Homebridge is installed
    # sudo hb-service rebuild --all
    # sudo hb-service install
    # sudo hb-service start
    
    # cleanup old install
    nvm uninstall $CURRENT
fi

exit 0
