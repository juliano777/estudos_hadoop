# ============================================================================

# HADOOP =====================================================================

# =======================================================================================
export SRV_1='hadoop-alpha'
export SRV_2='hadoop-beta'
export SRV_3='hadoop-gamma'
export SRV_1_IP='192.168.56.3'
export SRV_2_IP='192.168.56.4'
export SRV_3_IP='192.168.56.5'
# =======================================================================================



read -p 'Digite o hostname do primeiro servidor: ' SRV_1
read -p 'Digite o IP do primeiro servidor: ' SRV_1_IP
read -p 'Digite o hostname do segundo servidor: ' SRV_2
read -p 'Digite o IP do segundo servidor: ' SRV_2_IP
read -p 'Digite o hostname do terceiro servidor: ' SRV_3
read -p 'Digite o IP do terceiro servidor: ' SRV_3_IP



# The /etc/hosts file:

cat << EOF >> /etc/hosts
${SRV_1_IP} ${SRV_1}.local ${SRV_1}
${SRV_2_IP} ${SRV_2}.local ${SRV_2}
${SRV_3_IP} ${SRV_3}.local ${SRV_3}
EOF



# Create the system group for Hadoop:

groupadd -r hadoop



# Create the system user group for Hadoop:

useradd -rm \
    -c 'Hadoop User' \
    -s /bin/bash \
    -d /var/local/hadoop \
    -k /etc/skel \
    -g hadoop hadoop



# Environment variable for the Hadoop Version:

read -p 'Digite a versão (X.Y.Z) do Hadoop a ser baixada: ' HADOOP_VERSION



# Global profile for Hadoop Instalation:

cat << EOF > /etc/profile.d/hadoop.sh
#!/bin/bash

export HADOOP_HOME='/usr/local/hadoop'
export HADOOP_INSTALL="\${HADOOP_HOME}"
export PATH="\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin"
export HADOOP_MAPRED_HOME="\${HADOOP_HOME}"
export HADOOP_COMMON_HOME="\${HADOOP_HOME}"
export HADOOP_HDFS_HOME="\${HADOOP_HOME}"
export YARN_HOME="\${HADOOP_HOME}"
export HADOOP_COMMON_LIB_NATIVE_DIR="\${HADOOP_HOME}/lib/native"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${HADOOP_COMMON_LIB_NATIVE_DIR}"
export HADOOP_OPTS="-Djava.library.path=\${HADOOP_COMMON_LIB_NATIVE_DIR} \
                    -XX:-PrintWarnings \
                    -Djava.net.preferIPv4Stack=true \
                    -Dhadoop.root.logger=WARN"
export HADOOP_CONF_DIR="/etc/hadoop"
export HADOOP_LOG_DIR='/var/log/hadoop'
export HADOOP_TMP_DIR='/var/local/hadoop/tmp'
export HADOOP_DATANODE_DIR='/var/local/hadoop/hdfs/datanode'
export HADOOP_NAMENODE_DIR='/var/local/hadoop/hdfs/namenode'
export HDFS_NAMENODE_USER='hadoop'
export HDFS_DATANODE_USER='hadoop'
export HDFS_SECONDARYNAMENODE_USER='hadoop'
export YARN_RESOURCEMANAGER_USER='hadoop'
export YARN_NODEMANAGER_USER='hadoop'
export HADOOP_ROOT_LOGGER='WARN'

if [ -z \${CLASSPATH} ]; then
    export CLASSPATH="\${HADOOP_HOME}/share/hadoop/common/lib/"
else
    export CLASSPATH="\${HADOOP_HOME}/share/hadoop/common/lib/:\${CLASSPATH}"
fi
EOF



# Apply the Hadoop Profile:

source /etc/profile.d/hadoop.sh



# Directory where Hadoop installation will be:

cd /usr/local



# Download the Hadoop binary:

wget -c http://ftp.unicamp.br/pub/apache/hadoop/common/\
hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz



# Extract the package:

tar xf hadoop-${HADOOP_VERSION}.tar.gz



# Rename the Hadoop directory with version to hadoop:

mv hadoop-${HADOOP_VERSION} hadoop



# Remove the downloaded package:

rm -f hadoop-${HADOOP_VERSION}.tar.gz



# Remove the garbage files:

find hadoop/ -name *.cmd -delete



# Move the Hadoop configuration directory to /etc:

mv hadoop/etc/hadoop /etc/



# SSH keys:

su - hadoop -c "\
    ssh-keygen \
        -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub \
    > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/*"



# The main Hadoop configuration file:

cat << EOF > ${HADOOP_CONF_DIR}/core-site.xml
<configuration>
<property>
        <name>fs.defaultFS</name>
        <value>hdfs://${SRV_1}:9000/</value>
</property>
<property>
        <name>dfs.permissions</name>
        <value>false</value>
</property>
<property>
        <name>hadoop.tmp.dir</name>
        <value>${HADOOP_TMP_DIR}</value>
</property>
</configuration>
EOF



# The HDFS configuration file:

cat << EOF > ${HADOOP_CONF_DIR}/hdfs-site.xml
<configuration>
<property>
 <name>dfs.secondary.http.address</name>
        <value>${SRV_1}:50090</value>
        <description>Secondary NameNode hostname</description>
</property>
<property>
        <name>dfs.data.dir</name>
        <value>${HADOOP_DATANODE_DIR}</value>
        <final>true</final>
</property>
<property>
        <name>dfs.name.dir</name>
        <value>${HADOOP_NAMENODE_DIR}</value>
        <final>true</final>
</property>
<property>
        <name>dfs.blocksize</name>
        <value>67108864</value>
</property>
<property>
        <name>dfs.replication</name>
        <value>3</value>
</property>
</configuration>
EOF



# The Map Reduce configuration file:

cat << EOF > ${HADOOP_CONF_DIR}/mapred-site.xml
<configuration>

<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>

<property>
    <name>mapreduce.map.memory.mb</name>
    <value>2048</value>
</property>

<property>
    <name>mapreduce.reduce.memory.mb</name>
    <value>4096</value>
</property>

</configuration>
EOF



# The Yarn configuration file:

cat << EOF > ${HADOOP_CONF_DIR}/yarn-site.xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>

    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_MAPRED_HOME}</value>
    </property>

    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_MAPRED_HOME}</value>
    </property>

    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_MAPRED_HOME}</value>
    </property>

    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>1</value>
    </property>

    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
    </property>

</configuration>
EOF



# hadoop-env.sh file:

cat << EOF > ${HADOOP_CONF_DIR}/hadoop-env.sh
source /etc/profile.d/jdk.sh
source /etc/profile.d/hadoop.sh
EOF



# masters file:

echo "${SRV_1}" > ${HADOOP_CONF_DIR}/masters



# workers file:

cat << EOF > ${HADOOP_CONF_DIR}/workers
${SRV_2}
${SRV_3}
EOF



# Directories creation:

mkdir -p ${HADOOP_LOG_DIR} ${HADOOP_DATANODE_DIR} ${HADOOP_NAMENODE_DIR}



# Change owner to user and group Hadoop:

chown -R hadoop: /usr/local/hadoop /var/{local,log}/hadoop /etc/hadoop/



# Format the name node:

su - hadoop -c 'hdfs namenode -format'



# Start Distributed File System:

su - hadoop -c 'start-dfs.sh'



# Start Yarn:

su - hadoop -c 'start-yarn.sh'



# Change to Hadoop system user:

su - hadoop



# Create a test directory in HDFS:

hdfs dfs -mkdir /teste



# Download a file (in this case, the Linux kernel) to /tmp directory:

wget -c https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.3.tar.xz -P /tmp



# Put the downloaded file to /teste directory in HDFS:

hdfs dfs -put /tmp/linux-4.15.3.tar.xz /teste/



# List the directory:

hdfs dfs -ls /teste

"
Found 1 items
-rw-r--r--   1 hadoop supergroup  102188708 2018-02-13 17:02 /teste/linux-4.15.3.tar.xz
"



# List the directory (with human readable option):

hdfs dfs -ls -h /teste

"
Found 1 items
-rw-r--r--   1 hadoop supergroup     97.5 M 2018-02-13 17:02 /teste/linux-4.15.3.tar.xz
"



# Get the file from the HDFS:

hdfs dfs -get /teste/linux-4.15.3.tar.xz /tmp/



# Check if the file is in the directory:

ls -lh /tmp/linux-4.15.3.tar.xz

"
-rw-r--r-- 1 hadoop hadoop 98M Feb 14 09:46 /tmp/linux-4.15.3.tar.xz
"

# Sair do modo de segurança:

hdfs dfsadmin -safemode leave

# check status of safemode

hdfs dfsadmin -safemode get

# Para casos em que há uma necessidade de ter um nível maior de informações:

export HADOOP_ROOT_LOGGER=DEBUG,console



# ============================================================================
# Starting Services Manually
# ============================================================================

# Start the data node service:

hdfs --config ${HADOOP_CONF_DIR} --daemon start datanode

"
9864
9866
9867
33582
"



# Start the journal node service:

hdfs --config ${HADOOP_CONF_DIR} --daemon start journalnode

"
8480
8485
"


# Start the name node service:

hdfs --config ${HADOOP_CONF_DIR} --daemon start namenode

"
9000
9870
"



# Start the secondary name node service:

hdfs --config ${HADOOP_CONF_DIR} --daemon start secondarynamenode

"
50090
"



# Start the HTTP FS service: 

hdfs --config ${HADOOP_CONF_DIR} --daemon start httpfs

"
14000
"



# Start the resource manager service:

yarn --config ${HADOOP_CONF_DIR} --daemon start resourcemanager

"
8030
8031
8032
8033
8088
"



# Java Process Status...

jps

"
105253 DataNode
105559 JournalNode
105960 ResourceManager
105706 SecondaryNameNode
107242 HttpFSServerWebServer
107373 Jps
105372 NameNode
"
