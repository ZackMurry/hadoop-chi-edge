#!/bin/bash

addgroup hadoop
adduser --ingroup hadoop --gecos "" --disabled-password hduser
#useradd -m -p "mypassword" -s /bin/bash hduser
chpasswd <<< "hduser:mypassword"
passwd -u hduser

#rc-service sshd restart

ls /root
cat bashrc_additions.sh >> /root/.bashrc
cat bashrc_additions.sh >> /home/hduser/.bashrc
source /home/hduser/.bashrc

cd /usr/src/app

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0-aarch64.tar.gz

