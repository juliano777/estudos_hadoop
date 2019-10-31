#!/bin/bash

"
Dependências

aws-java-sdk
aws-java-sdk-core
aws-java-sdk-dynamodb
aws-java-sdk-kms
aws-java-sdk-s3
hadoop-aws
httpclient
jackson-annotations
jackson-core
jackson-databind
joda-time
"



# Criar links simbólicos no diretório de bibliotecas para os arquivos .jar
# da AWS:

ls ${HADOOP_HOME}/share/hadoop/tools/lib/*aws-*.jar | \
    xargs -i ln -sf {} ${HADOOP_HOME}/share/hadoop/common/lib/



# Endereço de armazenamento S3:

read -p 'Digite o endereço do armazenamento S3: ' S3_ADDR



# Variável de ambiente para Access Key:

read -p 'Digite a Access Key: ' ACCESS_KEY



# Variável de ambiente para Secret Key:

read -p 'Digite a Secret Key: ' SECRET_KEY



# Variável de ambiente para a URL de WareHouse do Hive
# (e. g. s3a://<bucket>/dir):

read -p 'Digite a Secret Key: ' WAREHOUSE_URL



# Modificações no arquivo core-site.xml:

"
    <!-- S3 -->

    <property>
        <name>fs.s3a.endpoint</name>
        <description>AWS S3 endpoint to connect to.</description>
        <value>${S3_ADDR}</value>
    </property>

    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>${ACCESS_KEY}</value>
    </property>

    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>${SECRET_KEY}</value>
    </property>

    <property>
        <name>fs.s3a.path.style.access</name>
        <value>true</value>
        <description>Enable S3 path style access.</description>
    </property>

    <!-- ================================================================== -->
"


hadoop fs -put /boot/vmlinuz-4.17.3-jx s3a://foo/

hadoop fs -ls s3a://foo/*


cat << EOF > ${HIVE_HOME}/conf/hive-site.xml
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://localhost/db_metastore</value>
    </property>

    <property>
        <name>hive.aux.jars.path</name>
        <value>file:///usr/local/hive/lib</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>user_hive</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>123</value>
    </property>

   <property>
        <name>fs.s3a.endpoint</name>
        <description>AWS S3 endpoint to connect to.</description>
        <value>${S3_ADDR}</value>
    </property>

    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>${ACCESS_KEY}</value>
    </property>

    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>${SECRET_KEY}</value>
    </property>

    <property>
        <name>fs.s3a.path.style.access</name>
        <value>true</value>
        <description>Enable S3 path style access.</description>
    </property>

    <property>
        <name>datanucleus.autoCreateSchema</name>
        <value>true</value>
    </property>

    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>${WAREHOUSE_URL}</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>spark</value>
        <description>Chooses execution engine.</description>
    </property>

</configuration>
EOF

CREATE ROLE user_hive LOGIN ENCRYPTED PASSWORD '123';

CREATE DATABASE db_metastore OWNER user_hive;

schematool -initSchema -dbType postgres

hiveserver2 --service metastore &

hiveserver2 start &

cat << EOF >> $SPARK_CONF_DIR/spark-defaults.conf

spark.yarn.jars=file://${SPARK_HOME}/jars/*.jar,\
file://${HADOOP_HOME}/share/hadoop/common/lib/*.jar

spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
spark.hadoop.fs.s3a.endpoint=${S3_ADDR}
spark.hadoop.fs.s3a.access.key=${ACCESS_KEY}
spark.hadoop.fs.s3a.secret.key=${SECRET_KEY}
EOF
