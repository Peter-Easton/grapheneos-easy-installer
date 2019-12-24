#!/bin/bash
echo "Okay, let's prepare your computer for installing GrapheneOS!" 
if [ awk 'NR==2' /etc/*-release != 'NAME="Debian GNU/Linux"' ]; then 
    echo "This script is intended for Debian Buster 10."
    echo "This is script is intended for a different distro than the one you are running."
    echo "Please download the right installer for your operating system."
    echo "Installation will exit now."
    exit 1
fi

echo "Let's install some dependencies..."
echo "This script is intended for Debian on the x86-64 only." 
echo "Don't go away. I'm going to need your help in a bit to complete the installation."
sleep 4s

echo "Next up, we'll make sure that you don't have an outdated version of Fastboot or ADB on your system..."
sudo apt remove -y adb fastboot 

echo "And we'll install some dependencies." 
sudo apt install -y wget 
if [ $? = 1 ]; then
    echo "Some of the dependencies did not install correctly. Exiting now." 
    exit 1
fi

echo "Next, we'll get ahold of the most recent version of the android platform tools..."
if [ ! -d GrapheneOS ]; then 
    mkdir -p ~/GrapheneOS/
fi 
cd ~/GrapheneOS/
if [ -d platform-tools ]; then 
    echo "The platform-tools directory already exists. I will exit to avoid overwriting it."
    exit 1
fi 
if [ ! -f platform-tools-latest-linux.zip ]; then 
    wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    if [ $? = 1 ]; then
        echo "I couldn't find the latest platform tools." 
        echo "Exiting now."
        exit 1
    fi
    unzip platform-tools-latest-linux.zip
    export PATH=$PATH:~/GrapheneOS/platform-tools/
    echo "Platform tools has been downloaded and unpacked. The platform-tools-latest-linux.zip file may now be safely deleted."
    echo "Adding platform tools to your $PATH variable in your .bashrc file."
    echo "export PATH=$PATH:~/GrapheneOS/platform-tools/" >> ~/.bashrc
    echo ""
fi

echo "We're going to add some rules to your /etc/udev rules to allow your computer to talk to your phone via adb."

if [ ! -f /etc/udev/rules.d/51-android.rules ]; then
echo "You don't seem to have udev rules, so we'll download those now."
    sudo mkdir -p /etc/udev/rules.d/
    echo "I'm going to download the udev rules."
    wget https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
    if [ $? = 0 ]; then 
        sudo mv 51-android.rules /etc/udev/rules.d/51-android.rules
        sudo udevadm control --reload-rules
        sudo groupadd adbusers
        export MY_USERNAME=$(whoami)
        sudo usermod --append --groups adbusers $MY_USERNAME 
        echo "Installed udev rules and added your account to the adbusers group."
        echo "You will need to log off and log back in again or reboot for the group permissions to take effect."
        echo ""
        echo "If you are not certain what else to do and it still fails, reboot your computer." 
    fi
else
    echo "I noticed you already have a 51-android.rules file for Android." 
    echo "I won't touch it, but you will need to check to make sure that they're correct."
    echo "If Fastboot or ADB are hanging with no devices found, you may have incorrect udev rules."
    echo "Should this happen, run the following command:"
    echo ""
    echo "wget https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules && sudo mv 51-android.rules /etc/udev/rules.d/51-android.rules && sudo groupadd adbusers && export MY_USERNAME=$(whoami) && sudo usermod --append --groups adbusers $MY_USERNAME"
    echo ""
    echo "and then reboot your computer once it finishes." 
    echo ""
    sleep 5
fi
echo ""
    

echo "Now installing signify. Beware: the signify package in OpenBSD is very old and may be missing security updates."
sudo apt install -y signify-openbsd
if [ $? = 1 ]; then
    echo "The installation of the dependencies didn't go as planned. They may be missing or you may need to update."
    echo "Please note that this script is intended for Debian 10 and might not work on other systems."
    exit 1
fi

echo ""
echo "You now are ready to download and install GrapheneOS on this operating system."
echo ""
sleep 1
echo "Follow the instructions on https://grapheneos.org/install#enabling-oem-unlocking"
sleep 1
echo "Good luck."
sleep 1
exit 0 
