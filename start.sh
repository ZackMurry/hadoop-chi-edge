# Configure namenode/datanode

#iperf3 -s

if [ -z $NODE_TYPE ] ; then
  echo "ERROR: Expected NODE_TYPE to be defined"
  exit 1
fi

master_name="master"

if [ ! -f /opt/hadoop/initialized ] ; then
  echo "Creating $device_host as $node_type"
  # (either "namenode" or "datanode")
  echo "Creating node as $NODE_TYPE"
  runuser -u hduser -- mkdir /opt/hadoop/hdfs/$NODE_TYPE
fi

# Replace master with actual hostname in config.xml files
#cd /opt/hadoop/etc/hadoop
#sed -i -e "s/master/$master_name/g" core-site.xml
#sed -i -e "s/master/$master_name/g" yarn-site.xml
#sed -i -e "s/master/$master_name/g" hdfs-site.xml
#sed -i -e "s/master/$master_name/g" mapred-site.xml


cd /opt/hadoop

ls -R /home/hduser/.ssh
echo "ls /etc/ssh"
ls /etc/ssh

chown hduser:hadoop /home/hduser/.ssh
chmod 700 /home/hduser/.ssh
chmod 644 /home/hduser/.ssh/id_rsa.pub
chmod 600 /home/hduser/.ssh/id_rsa
chmod 755 /home/hduser

# Start SSHd on port 30022
mkdir -p /run/sshd
chmod 755 /run/sshd
/usr/sbin/sshd -p 30022

sleep 5

# Is sshd running?

#cat /etc/ssh/sshd_config

netstat -tupan
#telnet localhost 30022

#echo "ssh -p 30022 hduser@localhost ls /"
#ssh -p 30022 hduser@localhost ls /
#echo "ssh -p 30022 hduser@127.0.0.1 ls /"
#ssh -p 30022 hduser@127.0.0.1 ls /
#echo "ssh -p 30022 hduser@10.188.2.111 ls /"
#ssh -o StrictHostKeyChecking=no -p 30022 hduser@10.188.2.111 ls /
#echo "ssh -p 30022 hduser@10.42.153.0 ls /"
#ssh -p 30022 hduser@10.42.153.0 ls /
#echo "ssh -p 30022 hduser@10.42.153.1 ls /"
#ssh -p 30022 hduser@10.42.153.1 ls /

#cat /var/log/auth.log



#echo "Waiting for other servers to come online..."
#sleep 60s

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
    echo "Sharing SSH key with hduser@$node_ip on $node_name"
    echo "mypassword" | runuser -u hduser -- sshpass ssh-copy-id -f -i /home/hduser/.ssh/id_rsa.pub -p 30022 hduser@$node_ip
    ssh -p 30022 hduser@$node_ip cat .ssh/id_rsa.pub | tee -a /home/hduser/.ssh/authorized_keys
  done
fi

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
  sleep 10s
done
