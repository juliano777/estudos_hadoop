# ============================================================================
# Spark

# https://www.tutorialspoint.com/spark_sql/spark_sql_quick_guide.htm


cd /usr/local/

wget -c http://mirror.nbtelecom.com.br/apache/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz


tar xf spark-2.3.0-bin-hadoop2.7.tgz

rm -f spark-2.3.0-bin-hadoop2.7.tgz

mv spark-2.3.0-bin-hadoop2.7/ spark

find spark/ -name *.cmd -delete

cat << EOF > /etc/profile.d/spark.sh
export SPARK_HOME='/usr/local/spark'
export SPARK_CONF_DIR="\${SPARK_HOME}/conf"
export PATH="\${PATH}:\${SPARK_HOME}/bin"
export IPYTHON='1'
export PYSPARK_PYTHON='/bin/python3.6'
export PYSPARK_DRIVER_PYTHON='ipython3'
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
if [ -z \${CLASSPATH} ]; then
    export CLASSPATH="\${SPARK_HOME}/jars"
else
    export CLASSPATH="\${CLASSPATH}:\${SPARK_HOME}/jars"
fi
export SPARK_SCALA_VERSION='2.12.4'
export SPARK_LOCAL_IP="${SRV_1_IP}"
export SPARK_PUBLIC_DNS="${SRV_1}"
EOF

source /etc/profile.d/spark.sh

cp spark/conf/spark-defaults.conf.template spark/conf/spark-defaults.conf




cat << EOF > /tmp/emp.json
{"id" : 1201, "name" : "satish", "age" : 25},
{"id" : 1202, "name" : "krishna", "age" : 28},
{"id" : 1203, "name" : "amith", "age" : 39},
{"id" : 1204, "name" : "javed", "age" : 23},
{"id" : 1205, "name" : "prudvi", "age" : 23}
EOF

hdfs dfs -put /tmp/emp.json /tmp/

spark-shell

val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val dfs = sqlContext.read.json("/tmp/emp.json")

dfs.show()

+---+----+-------+
|age|  id|   name|
+---+----+-------+
| 25|1201| satish|
| 28|1202|krishna|
| 39|1203|  amith|
| 23|1204|  javed|
| 23|1205| prudvi|
+---+----+-------+

dfs.select("*").show()
+---+----+-------+
|age|  id|   name|
+---+----+-------+
| 25|1201| satish|
| 28|1202|krishna|
| 39|1203|  amith|
| 23|1204|  javed|
| 23|1205| prudvi|
+---+----+-------+


dfs.printSchema()

root
 |-- age: long (nullable = true)
 |-- id: long (nullable = true)
 |-- name: string (nullable = true)


dfs.select("name").show()

+-------+
|   name|
+-------+
| satish|
|krishna|
|  amith|
|  javed|
| prudvi|
+-------+

dfs.select("id", "name").show()

+----+-------+
|  id|   name|
+----+-------+
|1201| satish|
|1202|krishna|
|1203|  amith|
|1204|  javed|
|1205| prudvi|
+----+-------+

dfs.filter(dfs("age") > 23).select("id", "name").show()

+----+-------+
|  id|   name|
+----+-------+
|1201| satish|
|1202|krishna|
|1203|  amith|
+----+-------+

dfs.groupBy("age").count().show()
+---+-----+
|age|count|
+---+-----+
| 39|    1|
| 25|    1|
| 28|    1|
| 23|    2|
+---+-----+




https://www.cloudera.com/documentation/enterprise/5-6-x/topics/cdh_ig_hive_metastore_configure.html


FAILED SemanticException org.apache.hadoop.hive.ql.metadata.HiveException java.lang.RuntimeException: Unable to instantiate org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient

https://cwiki.apache.org/confluence/display/Hive/Hive+on+Spark%3A+Getting+Started









