# Configure namenode/datanode

#iperf3 -s

if [ -z $NODE_TYPE ] ; then
  echo "ERROR: Expected NODE_TYPE to be defined"
  exit 1
fi

node_type="$NODE_TYPE"
master_name="master"

# Configure namenode/datanode

#iperf3 -s
if [ ! -f /opt/hadoop/initialized ] ; then
  tar -xzf /usr/src/app/hadoop-3.4.0-aarch64.tar.gz -C /opt

  ls /opt
  mv /opt/hadoop-3.4.0 /opt/hadoop

  mkdir -p /opt/hadoop/hdfs
  chown hduser:hadoop -R /opt/hadoop

  cd /opt/hadoop/etc/hadoop

  echo "Inserting new files..."

  mv /usr/src/app/core-site.xml .
  mv /usr/src/app/hdfs-site.xml .
  mv /usr/src/app/yarn-site.xml .
  mv /usr/src/app/mapred-site.xml .

  jav_test=$(readlink -f /usr/bin/java | sed "s:bin/java::")
  echo $jav_test

  sed -i -e "s:# export JAVA_HOME=:export JAVA_HOME=$jav_test:g" /opt/hadoop/etc/hadoop/hadoop-env.sh
  echo "export HADOOP_SSH_OPTS=\"-p 30022 -o StrictHostKeyChecking=accept-new\"" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

  mkdir -p /home/hduser/.ssh
  chown hduser:hadoop /home/hduser/.ssh
  runuser -u hduser -- ssh-keygen -t rsa -b 4096 -f /home/hduser/.ssh/id_rsa -P ""
  runuser -u hduser -- touch /home/hduser/.ssh/authorized_keys
  echo "ls -la /home/hduser/.ssh"
  runuser -u hduser -- ls -la /home/hduser/.ssh
  runuser -u hduser -- chmod 700 /home/hduser/.ssh
  runuser -u hduser -- chmod 644 /home/hduser/.ssh/id_rsa.pub
  runuser -u hduser -- chmod 644 /home/hduser/.ssh/authorized_keys
  runuser -u hduser -- chmod 600 /home/hduser/.ssh/id_rsa
  runuser -u hduser -- chmod 600 /home/hduser/.ssh/id_rsa
  runuser -u hduser -- chmod 755 /home/hduser
  echo "ls -la /home/hduser/.ssh"
  runuser -u hduser -- ls -la /home/hduser/.ssh


  #rc-update add sshd
  #rc-status
  #rc-service sshd start

  sed -i -e "s/#Port 22/Port 30022/g" /etc/ssh/sshd_config
  sed -i -e "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g" /etc/ssh/sshd_config
  sed -i -e "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  sed -i -e "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
  #cat /etc/ssh/sshd_config
  #runuser -u hduser -- ssh-keygen -A
  #echo "ls /etc/ssh"
  #ls /etc/ssh
  #echo "Creating ssh hostkey"
  ssh-keygen -A

fi

cd /opt/hadoop


# Todo: just refer to hosts using "master", "worker1", etc instead of ids

# Replace master with actual hostname in config.xml files
cd /opt/hadoop/etc/hadoop
sed -i -e "s/master/$master_name/g" core-site.xml
sed -i -e "s/master/$master_name/g" yarn-site.xml
sed -i -e "s/master/$master_name/g" hdfs-site.xml
sed -i -e "s/master/$master_name/g" mapred-site.xml


cd /opt/hadoop

#ls -R /home/hduser/.ssh
#echo "ls /etc/ssh"
#ls /etc/ssh

chown hduser:hadoop /home/hduser/.ssh
chmod 700 /home/hduser/.ssh
chmod 644 /home/hduser/.ssh/id_rsa.pub
chmod 600 /home/hduser/.ssh/id_rsa
chmod 755 /home/hduser

# Start SSHd on port 30022
mkdir -p /run/sshd
chmod 755 /run/sshd
/usr/sbin/sshd -p 30022 -d > /home/hduser/sshd_log.txt 2>&1 &

sleep 5

# Is sshd running?

#cat /etc/ssh/sshd_config

#netstat -tupan
#telnet localhost 30022

#echo "ssh -p 30022 hduser@localhost ls /"
#ssh -p 30022 hduser@localhost ls /
#echo "ssh -p 30022 hduser@127.0.0.1 ls /"
#ssh -p 30022 hduser@127.0.0.1 ls /
#echo "ssh -p 30022 hduser@10.188.2.111 ls /"
#runuser -u hduser -- ssh -o StrictHostKeyChecking=accept-new -p 30022 hduser@10.188.2.111 ls /
#echo "ssh -p 30022 hduser@10.42.153.0 ls /"
#ssh -p 30022 hduser@10.42.153.0 ls /
#echo "ssh -p 30022 hduser@10.42.153.1 ls /"
#ssh -p 30022 hduser@10.42.153.1 ls /

#cat /var/log/auth.log



#echo "Waiting for other servers to come online..."
#sleep 60s
exit 0
echo "Testing password ssh auth"
runuser -u hduser -- sshpass -p "password" ssh -p 30022 -o StrictHostKeyChecking=accept-new hduser@$node_ip "ls /"

echo "cat /home/hduser/sshd_log.txt"
cat /home/hduser/sshd_log.txt


echo "ls -la /home/hduser/.ssh"
runuser -u hduser -- ls -la /home/hduser/.ssh

if [ ! -f /opt/hadoop/initialized ] ; then
  found_self=0
  for node in $(echo $NODES | tr ";" "\n")
  do
    node_name=$(echo $node | cut -f1 -d:)
    if [ "$found_self" -eq 0 -a "$node_name" != "$device_host" ] ; then
      echo "Skipping ssh-copy-id for $node_name because it starts after this node"
      continue
    fi
    found_self=1
    node_ip=$(echo $node | cut -f2 -d:)
    #echo "Testing password SSH"
    #runuser -u hduser -- sshpass -p "mypassword" ssh -p 30022 -o StrictHostKeyChecking=accept-new hduser@$node_ip ls /
    echo "Manually sharing SSH key with hduser@$node_ip on $node_name"
    cat /home/hduser/.ssh/id_rsa.pub | runuser -u hduser -- sshpass -p "password" ssh -p 30022 -o StrictHostKeyChecking=accept-new hduser@$node_ip 'cat >> /home/hduser/.ssh/authorized_keys'
    #runuser -u hduser -- sshpass -p "mypasssword" ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub -p 30022 hduser@$node_ip
    #echo "ls -la /home/hduser/.ssh"
    #runuser -u hduser -- ls -la /home/hduser/.ssh
    echo "cat /home/hduser/.ssh/authorized_keys"
    runuser -u hduser -- cat /home/hduser/.ssh/authorized_keys
    echo "Reversing ssh-copy-id..."
    runuser -u hduser -- ssh -p 30022 -o StrictHostKeyCHecking=accept-new hduser@$node_ip cat .ssh/id_rsa.pub | tee -a /home/hduser/.ssh/authorized_keys

  done
fi

echo "cat /home/hduser/sshd_log.txt"
cat /home/hduser/sshd_log.txt

if [ "$node_type" = "namenode" ] ; then
  if [ ! -f /opt/hadoop/initialized ] ; then
    runuser -u hduser -- bin/hdfs namenode -format
  fi
  echo "Starting namenode"
  runuser -u hduser -- sbin/start-dfs.sh
  runuser -u hduser -- sbin/start-yarn.sh
  runuser -u hduser -- bin/hdfs dfsadmin -report
else
  echo "Initialized data node"
fi

runuser -u hduser -- touch /opt/hadoop/initialized

while true
do
  echo "Staying active..."
  sleep 60s
done
