#!/bin/bash

"
Dependências

aws-java-sdk
aws-java-sdk-core
aws-java-sdk-kms
aws-java-sdk-s3
aws-java-sdk-dynamodb
hadoop-aws
hadoop-aws
httpclient
jackson-annotations
jackson-core
jackson-databind
joda-time
"


export HADOOP_VERSION='3.1.2'


export AWS_SDK_VERSION='1.11.517'
export JODA_TIME_VERSION='2.10.1'
export HADOOP_AWS_VERSION='3.1.2'



# Verifique no site a versão do AWS SDK For Java
# https://mvnrepository.com/artifact/com.amazonaws/aws-java-sdk

read -p 'Versão AWS SDK For Java: ' AWS_SDK_VERSION

wget -c http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/\
${AWS_SDK_VERSION}/aws-java-sdk-${AWS_SDK_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/

wget -c http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-core/\
${AWS_SDK_VERSION}/aws-java-sdk-core-${AWS_SDK_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/

wget -c http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-kms/\
${AWS_SDK_VERSION}/aws-java-sdk-kms-${AWS_SDK_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/

wget -c http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/\
${AWS_SDK_VERSION}/aws-java-sdk-s3-${AWS_SDK_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/

wget -c http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-dynamodb/\
${AWS_SDK_VERSION}/aws-java-sdk-dynamodb-${AWS_SDK_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/




# Verifique no site a versão do Joda Time
# https://mvnrepository.com/artifact/joda-time/joda-time

read -p 'Versão AWS SDK For Joda Time: ' JODA_TIME_VERSION

wget -c http://central.maven.org/maven2/joda-time/joda-time/\
${JODA_TIME_VERSION}/joda-time-${JODA_TIME_VERSION}.jar \
-P ${HADOOP_HOME}/share/hadoop/common/lib/


ln -s ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar \
${HADOOP_HOME}/share/hadoop/common/lib/



cat << EOF > /etc/hadoop/core-site.xml
<!-- core-site.xml -->
<configuration>
    <property>
        <name>fs.s3a.endpoint</name>
        <description>AWS S3 endpoint to connect to.</description>
        <value>http://192.168.56.4:9000</value>
    </property>

    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>5D0EN4B8SF7EYUJH1V8I</value>
    </property>

    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>BjtgRNuLHBSEUU4e2Yzz/lBVjoFVnIvCr6rGFRXo</value>
    </property>

    <property>
        <name>fs.s3a.path.style.access</name>
        <value>true</value>
        <description>Enable S3 path style access.</description>
    </property>

    <property>
        <name>fs.s3a.connection.timeout</name>
        <value>10</value>
    </property>

    <property>
        <name>fs.s3a.attempts.maximum</name>
        <value>1</value>
        <description>How many times we should retry commands on transient errors.</description>
    </property>

</configuration>
EOF


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

    <!-- 
    <property>
        <name>datanucleus.autoCreateSchema</name>
        <value>false</value>
    </property>
        
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hadoop-alpha:9083</value>
        <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
    </property>
    -->


    <property>
        <name>fs.s3a.endpoint</name>
        <description>AWS S3 endpoint to connect to.</description>
        <value>http://192.168.56.4:9000</value>
        <!-- NOTE: Above value is obtained from the minio start window -->
    </property>

    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>5D0EN4B8SF7EYUJH1V8I</value>
        <!-- NOTE: Above value is obtained from the minio start window -->
    </property>

    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>BjtgRNuLHBSEUU4e2Yzz/lBVjoFVnIvCr6rGFRXo</value>
        <!-- NOTE: Above value is obtained from the minio start window -->
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
        <value>s3a://hive/warehouse</value>
    </property>

    <!--
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>true</value>
    </property>
    -->

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
