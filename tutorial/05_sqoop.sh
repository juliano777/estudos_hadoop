# Sqoop =======================================================================

# Precisa de JDK

read -p 'Sqoop -> Digite a versão a ser baixada: ' SQOOP_VERSION

cd /usr/local


wget -c http://ftp.unicamp.br/pub/apache/sqoop/${SQOOP_VERSION}/sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz

tar xf sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz

mv sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0 sqoop

rm -f sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz

find sqoop/ -name *.cmd -delete

cat << EOF > /etc/profile.d/sqoop.sh
#!/bin/bash

export SQOOP_HOME='/usr/local/sqoop'

if [ -z \${CLASSPATH} ]; then
    export CLASSPATH="\${SQOOP_HOME}/lib"
else
    export CLASSPATH="\${CLASSPATH}:\${SQOOP_HOME}/lib"
fi

export PATH="\${PATH}:\${SQOOP_HOME}/bin"
EOF


source /etc/profile.d/sqoop.sh

# cat ${SQOOP_HOME}/conf/sqoop-env-template.sh > ${SQOOP_HOME}/conf/sqoop-env.sh


# Filme Transcendence

ln -s /usr/local/jdk/lib/postgresql-42.2.5.jar ${SQOOP_HOME}/lib/

ln -sf ${HIVE_HOME}/lib/hive-exec-3.0.0.jar ${SQOOP_HOME}/lib/

hdfs dfs -mkdir -p /db/pgsql/db_metastore

hdfs dfs -mkdir -p /db/pgsql/db_empresa

sqoop list-tables \
--connect jdbc:postgresql://127.0.0.1/db_metastore \
--username user_hive \
--password 123

sqoop list-tables \
--connect jdbc:postgresql://127.0.0.1/db_empresa \
--username postgres \
--password 123

sqoop import \
--connect jdbc:postgresql://127.0.0.1/db_empresa \
--username postgres --table tb_pf \
--password 123 \
--target-dir /db/pgsql/db_empresa/tb_pf \
--null-non-string '\\N'

# ===============================================================
export CONDITIONS='TRUE'

export COLUMNS='cpf, rg, nome, sobrenome, genero::text, dt_nascto, obs'

export SQL="SELECT ${COLUMNS} FROM tb_pf WHERE \$CONDITIONS;"


sqoop import \
--connect jdbc:postgresql://192.168.56.1:5432/db_empresa \
--username user_sqoop \
-P \
--target-dir /db/pgsql/db_empresa/table/pf \
--query "${SQL}" \
--input-fields-terminated-by ';' \
-m 1



sqoop export \
--connect jdbc:postgresql://192.168.56.1:5432/db_sqoop \
--username user_sqoop \
-P \
--export-dir /db/pgsql/db_empresa/table/pf \
--table tb_pf \
-- --schema public \
--input-fields-terminated-by ';' \
-m 1

# ===============================================================


sqoop eval \
--connect jdbc:postgresql://127.0.0.1:5432/db_metastore \
--username user_hive \
--password 123 \
--query 'SELECT * FROM "DBS"'



su - postgres

createdb db_carga

wget -c http://transparencia.al.gov.br/media/arquivo/comparativo_despesas-2016.zip -P /tmp/

cd /tmp/

unzip comparativo_despesas-2016.zip

iconv -f ISO-8859-1 -t UTF-8 comparativo_despesas-2016.txt > comparativo_despesas-2016.csv

sed -i 's/^M$//' comparativo_despesas-2016.csv

export CAMPOS=`head comparativo_despesas-2016.txt | head -1 | tr '[:upper:]' '[:lower:]' | sed 's/|/ text,\n/g'`


export TBL="CREATE TABLE tb_comparativo_despesas_al_2016(${CAMPOS} text);"

echo -e ${TBL} | sed 's/\r//g' > tb_comparativo_despesas_al_2016.sql

echo -e "\nCOPY tb_comparativo_despesas_al_2016 FROM '/tmp/comparativo_despesas-2016.csv' CSV HEADER DELIMITER '|';" >> tb_comparativo_despesas_al_2016.sql

psql -f tb_comparativo_despesas_al_2016.sql db_carga

