# Sqoop =======================================================================

cd /usr/local


wget -c http://ftp.unicamp.br/pub/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

tar xf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

mv sqoop-1.4.7.bin__hadoop-2.6.0 sqoop

rm -f sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

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


# Filme Transcendence

ln -s /usr/local/jdk/lib/postgresql-42.2.2.jar /usr/local/sqoop/lib/

sqoop list-tables --connect jdbc:postgresql://127.0.0.1/db_metastore --username user_hive

sqoop list-tables --connect jdbc:postgresql://127.0.0.1/db_empresa --username postgres

sqoop import --connect jdbc:postgresql://127.0.0.1/db_empresa --username postgres --table tb_pf --target-dir /db/pgsql/db_empresa/tb_pf --null-non-string '\\N'





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

