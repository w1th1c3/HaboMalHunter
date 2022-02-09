#!/bin/bash

set -x
set -e
#check root user
if [ "$(id -u)" != "0" ]; then
	echo "Please run as root"
fi

Uversion="xenial" 
echo -en "deb http://mirrors.aliyun.com/ubuntu/ ${Uversion} main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ ${Uversion} main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ ${Uversion}-security main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ ${Uversion}-security main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ ${Uversion}-updates main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ ${Uversion}-updates main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ ${Uversion}-backports main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ ${Uversion}-backports main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ ${Uversion}-proposed main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ ${Uversion}-proposed main restricted universe multiverse \n" >/etc/apt/sources.list


apt-get update
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
apt-get install -y nano binutils apt-utils net-tools tcpdump ltrace psmisc curl
pip install yara
ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so


curl -s https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add -
curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/stable/deb/draios.list
apt-get update
apt-get install -y build-essential sysdig tshark ssldump libcurl4-openssl-dev auditd
apt-get install -y dwarfdump linux-tools-common linux-headers-generic p7zip-rar zip volatility
apt-get install -y linux-tools-`uname -r`
apt-get install -y libc6-dev-i386 exiftool ssdeep upx clamav python python-pip python-dev python-software-properties

apt-get -y autoremove
apt-get clean all

#modify /etc/wireshark/init.lua
sed -i 's/run_user_scripts_when_superuser = false/run_user_scripts_when_superuser = true/' /etc/wireshark/init.lua
sed -i '38irunning_superuser = false' /etc/wireshark/init.lua

#build profile for volatility 
cd /usr/src/volatility-tools/linux
make
ls -la
cd -
VOL_PROFILE_DIR='/usr/share/vol_profile/'
rm -rf $VOL_PROFILE_DIR
mkdir -p $VOL_PROFILE_DIR
cp /usr/src/volatility-tools/linux/module.dwarf $VOL_PROFILE_DIR
cp /boot/System.map-`uname -r` $VOL_PROFILE_DIR
profile_file='/usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux/Ubuntu1604.zip'
rm -rf $profile_file
zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux/Ubuntu1404.zip $VOL_PROFILE_DIR/*
vol.py --info | grep Linux
echo "get the profile!"


# build lime
download_url='https://github.com/504ensicsLabs/LiME/archive/v1.7.5.zip'
dest_path='/usr/share/LiME'
dest_file='LiME.zip'
unzip_dir='LiME-1.7.5'
mkdir -p $dest_path
cd $dest_path
curl -o$dest_file -L $download_url
unzip -o -qq $dest_file 
cd $unzip_dir/src 
make
ls -la *.ko
cp *.ko $dest_path/'lime.ko'
cd ..
cd -

#install pyh.py
download_url='https://codeload.github.com/ilovegit1998/pyh/zip/master'
dest_path='/usr/share/pyh'
dest_file='pyh.zip'
unzip_dir='pyh-master'
mkdir -p $dest_path
cd $dest_path
curl -o$dest_file -L $download_url
unzip -o -qq $dest_file 
cd $unzip_dir
/usr/bin/python setup.py install
