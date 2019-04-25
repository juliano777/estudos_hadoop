# ============================================================================

# HADOOP =====================================================================

# =======================================================================================



# Python script to generate a file with IP and hostname for the hosts of the cluster:


cat << EOF > hosts_gen.py
from sys import argv
print()
N_HOSTS = int(input('How many servers will be part of the cluster?: '))
DOMAIN = input('Type the domain: ')
print()
hosts_dict = {}
with open(argv[1], '+wt') as f:
    for i in range(N_HOSTS):
        host_name = input('Hostname for the host {}: '.format(i))
        host_ip = input('IP for the the host {}: '.format(i))
        print()
        msg = '{} {} {}.{}\n'.format(host_ip, host_name, host_name, DOMAIN)
        f.write(msg)
EOF



# Execute the script (the first entry will be the master node):

python3 hosts_gen.py /tmp/myhosts



# Get the Namenode host:

read -p 'What is the Namenode? (IP / hostname / FQDN): ' NAME_NODE

export NAME_NODE



# Get the Secondary Namenode host:

read -p 'What is the Secondary Namenode? (IP / hostname / FQDN): ' S_NAME_NODE

export S_NAME_NODE



# Get the Yarn Resource Manager node host:

read -p 'What is the Yarn Resource Manager  Node? (IP / hostname / FQDN): ' \
YARN_RM_HOST

export YARN_RM_HOST



# Get the Yarn Resource Manager Scheduler node host:

read -p \
'What is the Yarn Resource Manager Scheduler? (IP / hostname / FQDN): ' \
YARN_RMS_HOST

export YARN_RMS_HOST



# Get the Yarn Node Manager node host:

read -p 'What is the Yarn Node Manager  Node? (IP / hostname / FQDN): ' \
YARN_NM_HOST

export YARN_NM_HOST



# The /etc/hosts file:

cat /tmp/myhosts >> /etc/hosts



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

eval "cat << EOF > ${HADOOP_CONF_DIR}/core-site.xml
`</tmp/core-site.xml`
EOF"



# The HDFS configuration file:

eval "cat << EOF > ${HADOOP_CONF_DIR}/hdfs-site.xml
`</tmp/hdfs-site.xml`
EOF"



# The Map Reduce configuration file:

cat /tmp/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml



# The Yarn configuration file:

eval "cat << EOF > ${HADOOP_CONF_DIR}/yarn-site.xml
`</tmp/yarn-site.xml`
EOF"



# hadoop-env.sh file:

cat << EOF > ${HADOOP_CONF_DIR}/hadoop-env.sh
source /etc/profile.d/jdk.sh
source /etc/profile.d/hadoop.sh
EOF



# masters file:

echo "${NAME_NODE}" > ${HADOOP_CONF_DIR}/masters



# workers file:

fgrep -v ${NAME_NODE} /tmp/myhosts | awk '{print $2}' > \
	${HADOOP_CONF_DIR}/workers




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



# ============================================================================
# Safe Mode
# ============================================================================



# Check status of safemode

hdfs dfsadmin -safemode get



# Exit from safe mode:

hdfs dfsadmin -safemode leave



# ============================================================================
# Log level
# ============================================================================



# For a higher log level:

export HADOOP_ROOT_LOGGER=DEBUG,console



# ============================================================================
# Starting Services Manually
# ============================================================================

# Start the namenode service:

hdfs --config ${HADOOP_CONF_DIR} \
    --workers \
    --hostnames `hdfs getconf -namenodes` \
    --daemon start namenode



# Start the datanode service:

hdfs --config ${HADOOP_CONF_DIR} --workers --daemon start datanode



# Start the secondary namenode service:

hdfs --config ${HADOOP_CONF_DIR} \
    --workers \
    --hostnames `hdfs getconf -secondaryNamenodes` \
    --daemon start secondarynamenode



# Start the journal node service:

hdfs --config ${HADOOP_CONF_DIR} --workers --daemon start journalnode



# Start the HTTP FS service: 

hdfs --config ${HADOOP_CONF_DIR} --daemon start httpfs



# Start the resource manager service:

yarn --config ${HADOOP_CONF_DIR} --daemon start resourcemanager



# Start the node manager service:

yarn --config ${HADOOP_CONF_DIR} --daemon start nodemanager



# Java Process Status:

jps



# Report:

hdfs dfsadmin -report



# Get a value from a configuration:

hdfs getconf -confKey yarn.scheduler.minimum-allocation-mb


# ============================================================================
# How to add a new node in cluster
# ============================================================================

# 0) Add the following properties:

# hdfs-site.xml

"
    <property>
        <name>dfs.hosts</name>
        <value>${HADOOP_CONF_DIR}/dfs.include</value>
        <final>true</final>
    </property>
"

# mapred-site.xml

"
    <property>
        <name>mapred.hosts</name>
        <value>${HADOOP_CONF_DIR}/dfs.include</value>
    </property>
"


# 1) Include the IP / hostname / FQDN of the datanode in 
# dfs.include and workers file in ${HADOOP_CONF_DIR}/
# This files must have all datanodes of the cluster.

# 2) In Namenode execute:

hdfs dfsadmin -refreshNodes

# 4) In new node execute:

hdfs --config ${HADOOP_CONF_DIR} --daemon start datanode





hdfs getconf -nameNodes


