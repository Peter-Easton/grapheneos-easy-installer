#!/bin/bash

echo "Let's install some dependencies..."
sudo apt install -y build-essential libbsd libbsd-devel gcc gmake
if [ $? = 1 ]
then
    echo "The installation of the dependencies didn't go as planned. They may be missing your you may need to update."
    exit 1
fi     

echo "Next up, we'll make sure that you don't have an outdated version of Fastboot or ADB on your system..."
sudo apt remove -y adb fastboot 

echo "Next, we'll get ahold of the most recent version of Android Debug Bridge..."

mkdir -p ~/GrapheneOS/'adb'
cd ~/GrapheneOS/'adb'
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
export PATH="$PATH"":/home/"$(who | awk ' { print $1 } ')"/GrapheneOS/adb/"

echo "And now signify for verifying your installation..." 

mkdir ~/GrapheneOS/signify-install && cd ~/GrapheneOS/signify-install
git clone https://github.com/aperezdc/signify.git 
cd signify
make && sudo make install
if [ $? = 1 ]
then
    echo "The installation of signify did not go as planned. You may be missing dependencies, they may be obsolete or too old, or something went wrong."
    exit 1
fi     

echo "We're going to add some rules to your /etc/udev rules to allow your computer to talk to your phone via adb."

sudo groupadd adbusers
sudo usermod $(who | awk ' { print $1 }') -G adbusers

sudo mkdir -p /etc/udev/rules.d/

sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",MODE="0660",GROUP="adbusers"" > /etc/udev/rules.d/51-android.rules
sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",ATTR{idProduct}=="[4ee2]",SYMLINK+="android_adb"" > /etc/udev/rules.d/51-android.rules
sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",ATTR{idProduct}=="[4ee2]",SYMLINK+="android_fastboot"" > /etc/udev/rules.d/51-android.rules

echo "We'll now get your factory images for Blueline..." 

mkdir ~/GrapheneOS/factory-images/
cd ~/GrapheneOS/factory-images/

wget https://releases.grapheneos.org/blueline-factory-2019.07.01.21.zip https://releases.grapheneos.org/blueline-factory-2019.07.01.21.zip.sig https://releases.grapheneos.org/factory.pub

echo "Done. You're almost ready. Let's verify." 
echo ""
echo "'"$(awk 'NR==2' factory.pub)"'" 
echo "is the key we have downloaded. You should check it against the images which are cross posted on the official GrapheneOS Twitter account, the /u/GrapheneOS reddit account, and on Github."
sleep 5s
echo ""
echo "I'm now checking to see if the software you downloaded was indeed signed by that key. Please wait."

signify -Cqp factory.pub -x blueline-factory-2019.07.01.21.zip.sig 

if [ $? = 0 ]
then
    echo "I got a good signature from "$(awk 'NR==2' factory.pub)", so let's proceed with the installation."
    echo "Unzipping the archive, please wait..."
    unzip blueline-factory-2019.07.01.21.zip
    echo "Done."
    echo ""
    cd blueline-*
    echo "Look in "$(pwd)" for the flash-all.sh script."
    echo ""
    echo "You'll have to take it from here to set up your phone for flashing. Follow the instructions on https://grapheneos.org/install#enabling-oem-unlocking and continue from there." 
    sleep 1s
    echo "Good luck and see you on the other side."
    exit 0    
else
    echo "Stop! This digital signature does not match "$(awk 'NR==2' factory.pub)". Check your sources and download again."
    exit 1
fi
