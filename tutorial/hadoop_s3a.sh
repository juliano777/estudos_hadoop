#!/bin/bash

"
aws-java-sdk-1.11.43.jar
    aws-java-sdk-core-1.11.43.jar
    aws-java-sdk-kms-1.11.43.jar
    aws-java-sdk-s3-1.11.43.jar
    aws-java-sdk-dynamodb
    hadoop-aws-2.7.1.jar
    hadoop-aws-3.0.0-alpha1.jar
    httpclient-4.5.2.jar
    jackson-annotations-2.8.4.jar
    jackson-core-2.8.4.jar
    jackson-databind-2.8.4.jar
    joda-time-2.9.4.jar
"


export HADOOP_VERSION='3.1.1'


export AWS_SDK_VERSION='1.11.463'
export JODA_TIME_VERSION='2.10.1'
export HADOOP_AWS_VERSION='3.1.1'



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
<!--
    <property>
            <name>fs.defaultFS</name>
            <value>hdfs://hadoop-alpha:9000/</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/var/lib/hadoop/tmp</value>
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
</configuration>
EOF



hadoop fs -put /boot/vmlinuz-4.17.3-jx s3a://foo/

hadoop fs -ls s3a://foo/*

