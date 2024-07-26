#!/bin/bash

addgroup hadoop
adduser --ingroup hadoop --gecos "" --disabled-password hduser
chpasswd <<< "hduser:mypassword"
mkdir -p /home/hduser/.ssh
chown hduser:hadoop /home/hduser/.ssh
runuser -u hduser -- ssh-keygen -t rsa -b 4096 -f /home/hduser/.ssh/id_rsa -P ""


#rc-update add sshd
#rc-status
#rc-service sshd start

sed -i -e "s/#Port 22/Port 30022/g" /etc/ssh/sshd_config
sed -i -e "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g" /etc/ssh/sshd_config
cat /etc/ssh/sshd_config
#runuser -u hduser -- ssh-keygen -A
echo "ls /etc/ssh"
ls /etc/ssh
echo "Creating ssh hostkey"
ssh-keygen -A
echo "ls /etc/ssh"
ls /etc/ssh

#rc-service sshd restart

ls /root
cat bashrc_additions.sh >> /root/.bashrc
cat bashrc_additions.sh >> /home/hduser/.bashrc
source /home/hduser/.bashrc

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
tar -xzf /usr/src/app/hadoop-3.4.0.tar.gz -C /opt

mv /opt/hadoop-3.4.0 /opt/hadoop

mkdir -p /opt/hadoop/hdfs
chown hduser:hadoop -R /opt/hadoop

cd /opt/hadoop

ls /opt/hadoop


echo "/opt/hadoop/etc/hadoop/core-site.xml"
cat /opt/hadoop/etc/hadoop/core-site.xml

echo "/opt/hadoop/etc/hadoop/hdfs-site.xml"
cat /opt/hadoop/etc/hadoop/hdfs-site.xml

echo "/opt/hadoop/etc/hadoop/yarn-site.xml"
cat /opt/hadoop/etc/hadoop/yarn-site.xml

echo "/opt/hadoop/etc/hadoop/mapred-site.xml"
cat /opt/hadoop/etc/hadoop/mapred-site.xml

cd /opt/hadoop/etc/hadoop

echo "Inserting new files..."

mv /usr/src/app/core-site.xml .
mv /usr/src/app/hdfs-site.xml .
mv /usr/src/app/yarn-site.xml .
mv /usr/src/app/mapred-site.xml .

echo "/opt/hadoop/etc/hadoop/core-site.xml"
cat /opt/hadoop/etc/hadoop/core-site.xml

echo "/opt/hadoop/etc/hadoop/hdfs-site.xml"
cat /opt/hadoop/etc/hadoop/hdfs-site.xml

echo "/opt/hadoop/etc/hadoop/yarn-site.xml"
cat /opt/hadoop/etc/hadoop/yarn-site.xml

echo "/opt/hadoop/etc/hadoop/mapred-site.xml"
cat /opt/hadoop/etc/hadoop/mapred-site.xml


#echo "/opt/hadoop/etc/hadoop/hadoop-env.sh"
#cat /opt/hadoop/etc/hadoop/hadoop-env.sh

jav_test=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo $jav_test

sed -i -e "s:# export JAVA_HOME=:export JAVA_HOME=$jav_test:g" /opt/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_SSH_OPTS=\"-p 30022\"" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

echo "/opt/hadoop/etc/hadoop/hadoop-env.sh"
cat /opt/hadoop/etc/hadoop/hadoop-env.sh

#cd /opt/hadoop
#bin/hdfs namenode -format

# todo: namenode and datanode images

