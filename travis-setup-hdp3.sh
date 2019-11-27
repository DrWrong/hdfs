#!/bin/sh

set -e

UBUNTU_VERSION=$(lsb_release -r | awk '{print substr($2,0,2)}')

sudo tee /etc/apt/sources.list.d/hdp.list <<EOF
deb http://public-repo-1.hortonworks.com/HDP/ubuntu16/3.x/updates/3.1.0.0 HDP main
EOF

sudo apt-get update

sudo mkdir -p /etc/hadoop/conf
sudo tee /etc/hadoop/conf/core-site.xml <<EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

sudo tee /etc/hadoop/conf/hdfs-site.xml <<EOF
<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/opt/hdfs/name</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/opt/hdfs/data</value>
  </property>
  <property>
   <name>dfs.permissions.superusergroup</name>
   <value>hadoop</value>
  </property>
</configuration>
EOF

sudo apt-get install -y --allow-unauthenticated hadoop hadoop-hdfs

sudo mkdir -p /opt/hdfs/data /opt/hdfs/name
sudo chown -R hdfs:hdfs /opt/hdfs

echo "HADOOP_HOME: $HADOOP_HOME"
echo "HADOOP_YARN_HOME: $HADOOP_YARN_HOME"
export HADOOP_YARN_HOME=$HADOOP_HOME
ls -lah $HADOOP_YARN_HOME

sudo -u hdfs hdfs namenode -format -nonInteractive

sudo adduser travis hadoop

sudo /usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode
sudo /usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh start namenode

hdfs dfsadmin -safemode wait
