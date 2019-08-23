#!/bin/bash
echo "Okay, let's prepare your computer for installing GrapheneOS! Let's install some dependencies..."
echo "This script is intended for Debian or Ubuntu hosts on the x86-64 only." 
echo "Don't go away. I'm going to need your help in a bit to complete the installation."
sleep 4s
sudo apt install signify-openbsd

# NOTE 1: This commented section is intended for those who wish to compile signify from source.
# Doing so is not recommended, as it leaves you without trust to bootstrap from, and leaves
# you trusting Github and TLS (and all the certificate authorities there) to provide you 
# with authentic source code for signify, thus breaking the chain of trust and increasing
# the attack surface to everyone above.
#
# sudo apt install -y build-essential libbsd libbsd-devel gcc gmake

if [ $? = 1 ]
then
    echo "The installation of the dependencies didn't go as planned. They may be missing or you may need to update."
    echo "Also, uh, you are running Debian or Ubuntu, aren't you?" 
    exit 1
fi     

echo "Next up, we'll make sure that you don't have an outdated version of Fastboot or ADB on your system..."
sudo apt remove -y adb fastboot 

echo "Next, we'll get ahold of the most recent version of Android Debug Bridge..."

mkdir -p ~/GrapheneOS/'Android Debug Bridge'
cd ~/GrapheneOS/'Android Debug Bridge'
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
if [ $? = 1 ]
then
    echo "Aw darn it. I couldn't find the latest platform tools. The download link may have changed. You'll need to go and download the latest platform tools for your operating system." 
    exit 1
fi
unzip platform-tools-latest-linux.zip
export PATH="$PATH"":~/GrapheneOS/'Android Debug Bridge'/"


# This section of the script down below is intended for those who wish to compile the signify package
# from source, rather than trust your operating system's preauthenticated binary package repositories.
# Once again, this is a harmful use case and has been commented out as a harm reduction strategy.
# Nevertheless, it has been left in place. 
# Please see Note 1 above for the reasons why this is not done. 
# 
#echo "And now signify for verifying your installation... The most recent version we should obtain and compile from source." 
#mkdir ~/GrapheneOS/signify-install && cd ~GrapheneOS/signify-install
#git clone https://github.com/aperezdc/signify.git 
#cd signify
#make && sudo make install
#if [ $? = 1 ]
#then
#    echo "The installation of signify didn't go as I'd hoped. You might be missing dependencies, they may be obsolete or too old, or something went wrong."
#    exit 1
#fi     

echo "We're going to add some rules to your /etc/udev rules to allow your computer to talk to your phone via adb."

sudo groupadd adbusers
export MY_USERNAME=$(whoami)
sudo usermod $(echo $MY_USERNAME) -G adbusers

sudo mkdir -p /etc/udev/rules.d/

sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",MODE="0660",GROUP="adbusers"" > /etc/udev/rules.d/51-android.rules
sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",ATTR{idProduct}=="[4ee2]",SYMLINK+="android_adb"" > /etc/udev/rules.d/51-android.rules
sudo echo "SUBSYSTEM=="usb",ATTR{idVendor}=="[18d1]",ATTR{idProduct}=="[4ee2]",SYMLINK+="android_fastboot"" > /etc/udev/rules.d/51-android.rules

echo "We'll now get your factory images for Blueline..." 

mkdir ~/GrapheneOS/factory-images/
cd ~/GrapheneOS/factory-images/

wget https://releases.grapheneos.org/blueline-factory-2019.08.05.19.zip https://releases.grapheneos.org/blueline-factory-2019.08.05.19.zip.sig https://releases.grapheneos.org/factory.pub

echo "Done. You're almost ready. Let's verify." 
echo ""
echo "'"$(awk 'NR==2' factory.pub)"'" 
echo "is the key we have downloaded. You should check it against the images which are cross posted on the official GrapheneOS Twitter account, the /u/GrapheneOS reddit account, and on Github."
echo "After this is done but before you start installing, you should check it to make sure it's the real deal." 
sleep 5s
echo ""
echo "I'm now checking to see if the software you downloaded was indeed signed by that key. Please wait."

signify -Cqp factory.pub -x blueline-factory-2019.08.05.19.zip.sig 

if [ $? = 0 ]
then
    echo "I got a good signature from "$(awk 'NR==2' factory.pub)", so let's proceed with the installation."
    echo "Unzipping the archive, please wait..."
    unzip blueline-factory-2019.08.05.19.zip
    echo "Done."
    echo ""
    cd blueline-*
    echo "You're now ready to install GrapheneOS on your Google Pixel 3." 
    sleep 1s  
    echo "If you get stuck, visit: https://grapheneos.org/install#flashing-factory-images for help."
    echo "Good luck and see you on the other side."
    exit 0    
else
    echo "Stop! This digital signature does not match "$(awk 'NR==2' factory.pub)". Check your source and download again."
    exit 1
fi


