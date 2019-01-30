# Hive =======================================================================

cd /usr/local

read -p 'Digite a versão (X.Y.Z) do Hive a ser baixada: ' HIVE_VERSION

wget -c http://ftp.unicamp.br/pub/apache/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz

tar xf apache-hive-${HIVE_VERSION}-bin.tar.gz

mv apache-hive-${HIVE_VERSION}-bin hive

rm -f apache-hive-${HIVE_VERSION}-bin.tar.gz


cat << EOF > /etc/profile.d/hive.sh
#!/bin/bash

export HIVE_HOME='/usr/local/hive'
export HIVE_CONF_DIR="\${HIVE_HOME}/conf"
export HADOOP_CLASSPATH="\${HADOOP_CLASSPATH}:\${HIVE_HOME}/lib"
export HIVE_PORT='10000'

if [ -z \${CLASSPATH} ]; then
    export CLASSPATH="\${HIVE_HOME}/lib"
else
    export CLASSPATH="\${CLASSPATH}:\${HIVE_HOME}/lib"
fi

export PATH="\${PATH}:\${HIVE_HOME}/bin"
EOF

source /etc/profile.d/hive.sh

cp ${HIVE_HOME}/conf/hive-env.sh.template ${HIVE_HOME}/conf/hive-env.sh

rpm -Uvh https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

wget -c https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -P /usr/local/jdk/lib/

cat << EOF > ${HIVE_HOME}/conf/hive-site.xml
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://localhost/db_metastore</value>
    </property>

    <property>
        <name>hive.aux.jars.path</name>
        <value>file://${HIVE_HOME}/lib</value>
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
        <name>datanucleus.autoCreateSchema</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${SRV_1}:9083</value>
        <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
    </property>

    <property>
        <name>hive.metastore.schema.verification</name>
        <value>true</value>
    </property>

    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>${SRV_1}</value>
    </property>

    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>

    <property>
        <name>hive.server2.authentication</name>
        <value>NOSASL</value>
    </property>

    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
        <description>
        Setting this property to true will have HiveServer2 execute
        Hive operations as the user making the calls to it.
        </description>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>spark</value>
        <description>Chooses execution engine.</description>
    </property>

</configuration>
EOF


schematool -initSchema -dbType postgres

hiveserver2 --service metastore &

hiveserver2 start &

CREATE ROLE user_hive LOGIN ENCRYPTED PASSWORD '123';

CREATE DATABASE db_metastore OWNER user_hive;

#psql -f ${HIVE_HOME}/scripts/metastore/upgrade/postgres/hive-schema-2.3.0.postgres.sql -U user_hive db_metastore

cat << EOF > /tmp/carros.csv
1;Ford;Corcel;1987
2;Fiat;147;1985
3;Volkswagen;Kombi;1982
4;Chevrolet;Opala;1979
EOF

hdfs dfs -put /tmp/carros.csv /teste/

hive

CREATE DATABASE db_teste;

USE db_teste;

CREATE EXTERNAL TABLE tb_carro (
    id int,
    marca string,
    modelo string,
    ano int)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ';';


CREATE EXTERNAL TABLE IF NOT EXISTS tb_carro(
    id int,
    marca string,
    modelo string,
    ano int)
    COMMENT 'Carro'
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ';'
    STORED AS TEXTFILE
    location '/teste/';

** pesquisar formato parquet

#LOAD DATA INPATH '/teste/carros.csv' INTO TABLE tb_carro;

SELECT * FROM tb_carro;

1	Ford	Corcel	1987
2	Fiat	147	1985
3	Volkswagen	Kombi	1982
4	Chevrolet	Opala	1979
